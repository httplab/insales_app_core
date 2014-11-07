require 'observer'
require_relative 'sync_methods'

module InsalesAppCore
  module Synchronization
    class Synchronizer < Struct.new(:account_id)
      include Observable
      include ::InsalesAppCore::Synchronization::SyncMethods

      ENTITY_INTACT = 0
      ENTITY_CREATED = 1
      ENTITY_MODIFIED = 2
      ENTITY_DELETED = 3
      WILL_WAIT_FOR = 4
      STAGE = 5
      END_SYNC = 6
      REQUEST = 7
      BEGIN_SYNC = 8

      DEFAULT_SYNC_OPTIONS = {
        categories: true,
        collections: true,
        collects: true,
        products: true,
        images: true,
        variants: true,
        fields: true,
        fields_values: true,
        properties: true,
        characteristics: true,
        orders: true,
        order_lines: true,
        clients: true
      }

      def initialize(account_id, options = {})
        super(account_id)
        @account = Account.find(account_id)
        normalize_sync_options(options[:sync])
      end

      def safe_api_call(&block)
        begin
          request(nil)
          yield
        rescue ActiveResource::ServerError => ex
          raise ex if "503" != ex.response.code.to_s
          retry_after = ex.response['Retry-After']
          retry_after = retry_after.present? ? retry_after.to_i : 150
          changed
          notify_observers(WILL_WAIT_FOR, retry_after, account_id)
          sleep(retry_after)
          retry
        end
      end

      def sync_categories
        remote_categories = safe_api_call{InsalesApi::Category.all}

        remote_categories.each do |remote_category|
          local_category = Category.update_or_create_by_insales_entity(remote_category, account_id: account_id)
          update_event(local_category, remote_category)
          local_category.save!(validate: false)
        end

        local_categories = Category.where(account_id: account_id)
        remote_categories_ids = remote_categories.map(&:id)

        local_categories.each do |local_category|
          if !remote_categories_ids.include?(local_category.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_category, nil, account_id)
            local_category.delete
            next
          end
        end
      end

      def sync_properties
        remote_ids = []
        remote_properties = safe_api_call{InsalesApi::Property.all}
        remote_properties.each do |remote_property|
          begin
            remote_ids << remote_property.id
            local_property = Property.update_or_create_by_insales_entity(remote_property, account_id: account_id)
            update_event(local_property, remote_property)
            local_property.save!(validate: false)
          rescue => ex
            puts ex.message
            puts ex.backtrace

            if local_property
              p local_property
              p local_property.attributes
            end
          end
        end

        if remote_ids.any?
          Property.where(account_id: account_id).where('properties.insales_id NOT IN (?)', remote_ids).each do |property|
            changed
            notify_observers(ENTITY_DELETED, property, nil, account_id)
            property.delete
          end
        end
      end

      def sync_products(updated_since = nil)
        remote_ids = []

        get_paged(InsalesApi::Product, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_product|

            next if category_id.nil?
            begin
              local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id)
              update_event(local_product, remote_product)
              local_product.save!(validate: false)
              sync_variants(remote_product) if @sync_options[:variants]
              sync_images(remote_product) if @sync_options[:images]
              sync_characteristics(remote_product) if @sync_options[:characteristics]
            rescue => ex
              puts ex.message
              if local_product
                p local_product
                p local_product.attributes
              end
            end
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Product.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_variants(remote_product)
        remote_variants = remote_product.variants
        remote_ids = remote_variants.map(&:id)

        if remote_ids.any?
          deleted = Variant.where('account_id = ? AND insales_product_id = ? AND insales_id NOT IN (?)', account_id, remote_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end

        remote_variants.each do |remote_variant|
          begin
            local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, insales_product_id: remote_product.id)
            update_event(local_variant, remote_variant)
            local_variant.save!(validate: false)
          rescue => ex
            puts ex.message
            puts remote_variant.inspect
          end
        end
      end

      def sync_images(insales_product)
        remote_images = insales_product.images

        remote_images.each do |remote_image|
          begin
            local_image = Image.update_or_create_by_insales_entity(remote_image, account_id: account_id, insales_product_id: insales_product.id)
            update_event(local_image, remote_image)
            local_image.save!(validate: false)
          rescue => ex
            puts ex.message
            puts remote_image.inspect
          end
        end

        remote_ids = remote_images.map(&:id)

        if remote_ids.any?
          deleted = Image.where('account_id = ? AND insales_product_id = ? AND insales_id NOT IN (?)', account_id, remote_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_characteristics(remote_product)
        product_characteristics_ids = []

        remote_product.characteristics.each do |remote_characteristic|
          begin
            local_characteristic = Characteristic.update_or_create_by_insales_entity(remote_characteristic, account_id: account_id)
            update_event(local_characteristic, remote_characteristic)
            local_characteristic.save!(validate: false)
            product_characteristics_ids << remote_characteristic.id
          rescue => ex
            puts ex.message
            p remote_characteristic
            p local_characteristic if local_characteristic
          end
        end

        local_product.characteristic_ids = product_characteristics_ids
      end

      def sync_fields
        remote_fields = safe_api_call{InsalesApi::Field.all}
        remote_ids = remote_fields.map(&:id)
        remote_fields.each do |remote_field|
          local_field = Field.update_or_create_by_insales_entity(remote_field, account_id: account_id)
          update_event(local_field, remote_field)
          local_field.save!(validate: false)
        end

        if remote_ids.any?
          deleted = Field.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_orders(updated_since = nil)
        get_paged(InsalesApi::Order, 250, updated_since: updated_since) do |page_result|
          page_result.each do |remote_order|
            sync_one_order(remote_order)
          end
        end

        delete_remotely_deleted_orders(updated_since)
      end

      def delete_remotely_deleted_orders(updated_since = nil)
        remote_ids = []
        puts updated_since
        get_paged(InsalesApi::Order, 250, updated_since: updated_since, deleted: true) do |page_result|
          remote_ids += page_result.map(&:id)
        end

        puts '-------------'
        puts remote_ids
        puts remote_ids.size


        if remote_ids.any?
          deleted = Order.where('account_id = ? AND insales_id IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_one_order(remote_order)
        local_order = Order.update_or_create_by_insales_entity(remote_order, account_id: account_id,)

        if remote_order.cookies.present?
          local_order.cookies = remote_order.cookies.attributes
        end

        update_event(local_order, remote_order)
        local_order.save!(validate: false)

        sync_fields_values(remote_order.fields_values, remote_order.id) if @sync_options[:fields_values]
        sync_order_lines(remote_order.order_lines, remote_order.id) if @sync_options[:order_lines]
        sync_order_shipping_address(remote_order.shipping_address, remote_order.id)
        true
      rescue => ex
        puts ex.message
        puts ex.backtrace
        p local_order
        if local_order
          p local_order.attributes
        end
        false
      end

      def sync_fields_values(remote_fields_values, insales_owner_id)
        remote_ids = remote_fields_values.map(&:id)
        remote_fields_values.each do |remote_fields_value|
          # Если в value содержится экземпляр класса InsalesApi::Order::FieldsValue::Value,
          # приводим его к строке
          value = remote_fields_value.value
          value = value.to_json unless value.is_a?(String)

          local_fields_value = FieldsValue.update_or_create_by_insales_entity(remote_fields_value,
            account_id: account_id, value: value, insales_owner_id: insales_owner_id)
          update_event(local_fields_value, remote_fields_value)
          local_fields_value.save!(validate: false)
        end

        if remote_ids.any?
          deleted = FieldsValue.where('account_id = ? AND owner_id = ? AND insales_id NOT IN (?)',
           account_id, owner_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted, account_id)
        end
      end

      def sync_order_lines(remote_order_lines, insales_order_id)
        remote_ids = remote_order_lines.map(&:id)

        remote_order_lines.each do |remote_order_line|
          local_order_line = OrderLine.update_or_create_by_insales_entity(remote_order_line,
            account_id: account_id, insales_order_id: insales_order_id)
          update_event(local_order_line, remote_order_line)
          local_order_line.save!(validate: false)
        end

        if remote_ids.any?
          deleted = OrderLine.where('account_id = ? AND order_id =? AND insales_id NOT in (?)',
            account_id, order_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted, account_id)
        end
      end

      def sync_order_shipping_address(remote_shipping_address, insales_order_id)
        sa = Order::ShippingAddress.update_or_create_by_insales_entity(remote_shipping_address, account_id: account_id, insales_order_id: order_id)
        sa.save!(validate: false)
      end

      def sync_clients(updated_since = nil)
        remote_ids = []
        puts updated_since
        get_paged(InsalesApi::Client, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_client|
            sync_one_client(remote_client)
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Client.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, account_id)
        end
      end

      def sync_one_client(remote_client)
        unless remote_client.is_a? InsalesApi::Client
          remote_client = InsalesApi::Client.find remote_client
        end

        local_client = Client.update_or_create_by_insales_entity(remote_client, account_id: account_id)
        update_event(local_client, remote_client)
        local_client.save!(validate: false)
        local_client
      rescue => ex
        puts ex.message
        puts ex.backtrace
        p local_client
        p local_client.attributes
      end

      def sync_collections
        remote_collections = safe_api_call{InsalesApi::Collection.all}

        remote_collections.each do |remote_collection|
          local_collection = Collection.update_or_create_by_insales_entity(remote_collection, account_id: account_id)
          update_event(local_collection)
          local_collection.save!(validate: false)
        end

        local_collections = Collection.where(account_id: account_id)
        remote_collections_ids = Set.new(remote_collections.map(&:id))

        local_collections.each do |local_collection|
          if !remote_collections_ids.include?(local_collection.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_collection, account_id)
            local_collection.delete
            next
          end
        end
      end

      def sync_collects
        remote_pairs = []

        get_paged(InsalesApi::Collect, 1000) do |page_result|
          page_result.each do |c|
            remote_pairs << [c.collection_id, c.product_id]
          end
        end

        local_pairs = Collect.where('account_id = ?', account_id).pluck(:insales_collection_id, :insales_product_id)

        pairs_to_delete = local_pairs - remote_pairs
        pairs_to_delete = pairs_to_delete.map {|p| "(#{p[0]},#{p[1]})"}.join(',')
        Collect.where('(collection_id, product_id) IN (?)', pairs_to_delete).delete_all if pairs_to_delete.present?

        pairs_to_create = remote_pairs - local_pairs
        values_clause = pairs_to_create.map {|v| "(#{v[0]},#{v[1]},#{account_id})"}.join(',')
        if pairs_to_create.any?
          Collect.connection.execute("INSERT INTO collects (collection_id, product_id, account_id) VALUES #{values_clause}")
        end
      end

      # Постраничное получение сущностей
      def get_paged(type, page_size = nil, addl_params = {})
        page = 1
        while true do
          params = {
            page: page
          }
          params[:per_page] = page_size if !page_size.nil?
          addl_params.delete_if{|k,v| v.nil?}
          params.merge!(addl_params)
          page_result = safe_api_call{type.find(:all, params: params)}

          # https://github.com/rails/activeresource/commit/c665bf3c7ccc834017a2168ee3c8a68a622b70e6
          # Пока это не попадет в релиз, придется использовать to_a
          return if page_result.to_a.empty?

          if(block_given?)
            yield page_result
          end

          page+=1
        end
      end

      # Методы для оповещения наблюдателей
      def update_event(entity, remote_entity = nil)
        changed
        if entity.new_record? || entity.changed?
          notify_observers(entity.new_record? ? ENTITY_CREATED : ENTITY_MODIFIED, entity, remote_entity, account_id)
        else
          notify_observers(ENTITY_INTACT, entity, remote_entity, account_id)
        end
      end

      def stage(stage)
        changed
        notify_observers(STAGE, stage, account_id)
      end

      def request(request)
        changed
        notify_observers(REQUEST, request, account_id)
      end

      def end_sync
        changed
        notify_observers(END_SYNC, account_id)
      end

      def begin_sync
        changed
        notify_observers(BEGIN_SYNC, account_id)
      end

      def normalize_sync_options(sync_options)
        @sync_options = DEFAULT_SYNC_OPTIONS.merge(sync_options || {})
        @sync_options[:fields] = @sync_options[:fields] || @sync_options[:fields_values]
        @sync_options
      end
    end
  end
end
