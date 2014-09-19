require 'observer'
require_relative 'sync_methods'

module InsalesAppCore
  module Synchronization
    class Synchronizer
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

      def safe_api_call(&block)
        begin
          request(nil)
          yield
        rescue ActiveResource::ServerError => ex
          raise ex if "503" != ex.response.code.to_s
          retry_after = ex.response['Retry-After']
          retry_after = retry_after.present? ? retry_after.to_i : 150
          changed
          notify_observers(WILL_WAIT_FOR, retry_after)
          sleep(retry_after)
          retry
        end
      end

      def sync_categories(account_id)
        remote_categories = safe_api_call{InsalesApi::Category.all}

        remote_categories.each do |remote_category|
          local_category = Category.update_or_create_by_insales_entity(remote_category, account_id: account_id)
          update_event(local_category, account_id, remote_category)
          local_category.save!
        end

        local_categories = Category.where(account_id: account_id)
        remote_categories_ids = remote_categories.map(&:id)
        tree_map = Category.ids_map

        local_categories.each do |local_category|
          if !remote_categories_ids.include?(local_category.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_category, nil, account_id)
            local_category.delete
            next
          end

          local_category.parent_id = tree_map[local_category.insales_parent_id]
          local_category.save!
        end
      end

      def sync_products(account_id, updated_since = nil)
        remote_ids = []
        @category_map = Category.ids_map

        get_paged(InsalesApi::Product, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)

          page_result.each do |remote_product|
            category_id = @category_map[remote_product.category_id]
            next if category_id.nil?
            begin
              local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id, category_id: category_id)
              update_event(local_product, account_id, remote_product)
              local_product.save!
              sync_variants(account_id, remote_product, local_product)
              sync_images(account_id, remote_product, local_product)
            rescue => ex
              puts ex.message
              if local_product
                p local_product
                p local_product.attributes
              end
              next
            end
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Product.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_variants(account_id, remote_product, local_product)
        remote_variants = remote_product.variants
        remote_ids = remote_variants.map(&:id)

        if remote_ids.any?
          deleted = Variant.where('account_id = ? AND product_id = ? AND insales_id NOT IN (?)', account_id, local_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end

        remote_variants.each do |remote_variant|
          begin
            local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, product_id: local_product.id)
            local_variant.insales_product_id ||= remote_product.id
            update_event(local_variant, account_id, remote_variant)
            local_variant.save!
          rescue => ex
            puts ex.message
            puts remote_variant.inspect
            next
          end
        end
      end

      def sync_images(account_id, insales_product, local_product)
        remote_images = insales_product.images

        remote_images.each do |remote_image|
          begin
            local_image = Image.update_or_create_by_insales_entity(remote_image, account_id: account_id, product_id: local_product.id)
            local_image.insales_product_id ||= insales_product.id
            update_event(local_image, account_id, remote_image)
            local_image.save!
          rescue => ex
            puts ex.message
            puts remote_image.inspect
            next
          end
        end

        remote_ids = remote_images.map(&:id)

        if remote_ids.any?
          deleted = Image.where('account_id = ? AND product_id = ? AND insales_id NOT IN (?)', account_id, local_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_fields(account_id)
        remote_fields = safe_api_call{InsalesApi::Field.all}
        remote_ids = remote_fields.map(&:id)
        remote_fields.each do |remote_field|
          local_field = Field.update_or_create_by_insales_entity(remote_field, account_id: account_id)
          update_event(local_field, account_id, remote_field)
          local_field.save!
        end

        if remote_ids.any?
          deleted = Field.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_orders(account_id, updated_since = nil)
        remote_ids = []
        puts updated_since
        get_paged(InsalesApi::Order, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_order|
            sync_one_order(remote_order, account_id)
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Order.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def self.sync_one_order(remote_order, account_id)
        insales_client_id = remote_order.client.id
        # Если случилось так, что клиента нет в БД (это может произойти если заказ был создан после того,
        # как мы синхронизировали клиенты, но еще не начали синхронизировать заказы).
        client = Client.find_by(insales_id: insales_client_id) || sync_one_client(insales_client_id, account_id)

        # Если клиента никак не удалось получить, кидаем исключение.
        unless client
          fail "sync_one_order: Client with insales_client_id=#{insales_client_id} not found in database"
        end

        hsh = {
          account_id: account_id,
          client_id: client.id,
          insales_client_id: insales_client_id
        }
        local_order = Order.update_or_create_by_insales_entity(remote_order, hsh)

        if remote_order.cookies.present?
          local_order.cookies = remote_order.cookies.attributes
        end

        update_event(local_order, account_id, remote_order)
        local_order.save!(:validate => false)

        sync_fields_values(remote_order.fields_values, account_id, local_order.id)
        sync_order_lines(remote_order.order_lines, account_id, local_order.id, remote_order.id)
        sync_order_shipping_address(remote_order.shipping_address, account_id, local_order.id)
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

      def sync_fields_values(remote_fields_values, account_id, owner_id)
        remote_ids = remote_fields_values.map(&:id)
        @fields_map = Field.ids_map

        remote_fields_values.each do |remote_fields_value|

          local_field_id = @fields_map[remote_fields_value.field_id.to_i]
          next if local_field_id.nil?
          local_fields_value = FieldsValue.update_or_create_by_insales_entity(remote_fields_value,
            account_id: account_id, owner_id: owner_id, field_id: local_field_id)
          update_event(local_fields_value, account_id, remote_fields_value)
          local_fields_value.save!(:validate => false)
        end

        if remote_ids.any?
          deleted = FieldsValue.where('account_id = ? AND owner_id = ? AND insales_id NOT IN (?)',
           account_id, owner_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def sync_order_lines(remote_order_lines, account_id, order_id, insales_order_id)
        remote_ids = remote_order_lines.map(&:id)
        @products_map = Product.ids_map
        @variants_map = Variant.ids_map

        remote_order_lines.each do |remote_order_line|
          local_product_id = @products_map[remote_order_line.product_id.to_i]
          local_variant_id = @variants_map[remote_order_line.variant_id.to_i]
          next if local_product_id.nil? || local_variant_id.nil?
          local_order_line = OrderLine.update_or_create_by_insales_entity(remote_order_line,
            account_id: account_id, order_id: order_id, product_id: local_product_id,
            variant_id: local_variant_id, insales_order_id: insales_order_id)
          update_event(local_order_line, account_id, remote_order_line)
          local_order_line.save!
        end

        if remote_ids.any?
          deleted = OrderLine.where('account_id = ? AND order_id =? AND insales_id NOT in (?)',
            account_id, order_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def sync_order_shipping_address(remote_shipping_address, account_id, order_id)
        sa = ShippingAddress.update_or_create_by_insales_entity(remote_shipping_address, account_id: account_id, order_id: order_id)
        sa.save!
      end

      def sync_clients(account_id, updated_since = nil)
        remote_ids = []
        puts updated_since
        get_paged(InsalesApi::Client, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_client|
            sync_one_client(remote_client, account_id)
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Client.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def sync_one_client(remote_client, account_id)
        unless remote_client.is_a? InsalesApi::Client
          remote_client = InsalesApi::Client.find remote_client
        end

        local_client = Client.update_or_create_by_insales_entity(remote_client, account_id: account_id)
        update_event(local_client, account_id, remote_client)
        local_client.save!(validate: false)
        local_client
      rescue => ex
        puts ex.message
        puts ex.backtrace
        p local_client
        p local_client.attributes
      end

      def sync_collections(account_id)
        remote_collections = safe_api_call{InsalesApi::Collection.all}

        remote_collections.each do |remote_collection|
          local_collection = Collection.update_or_create_by_insales_entity(remote_collection, account_id: account_id)
          update_event(local_collection, account_id)
          local_collection.save!
        end

        local_collections = Collection.where(account_id: account_id)
        remote_collections_ids = Set.new(remote_collections.map(&:id))
        tree_map = Collection.ids_map

        local_collections.each do |local_collection|
          if !remote_collections_ids.include?(local_collection.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_collection)
            local_collection.delete
            next
          end

          local_collection.parent_id = tree_map[local_collection.insales_parent_id]
          begin
            local_collection.save!
          rescue
            puts local_collection
            p local_collection
          end
        end
      end

      def sync_collects(account_id)
        remote_pairs = []
        collection_map = Collection.ids_map
        product_map = Product.ids_map

        get_paged(InsalesApi::Collect, 1000) do |page_result|
          page_result.each do |c|
            c_id = collection_map[c.collection_id]
            p_id = product_map[c.product_id]
            remote_pairs << [c_id, p_id] if c_id && p_id
          end
        end

        local_pairs = Collect.where('account_id = ?', account_id).pluck(:collection_id, :product_id)

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
      def update_event(entity, account_id, remote_entity = nil)
        changed
        if entity.new_record? || entity.changed?
          notify_observers(entity.new_record? ? ENTITY_CREATED : ENTITY_MODIFIED, entity, remote_entity, account_id)
        else
          notify_observers(ENTITY_INTACT, entity, remote_entity, account_id)
        end
      end

      def stage(stage)
        changed
        notify_observers(STAGE, stage)
      end

      def request(request)
        changed
        notify_observers(REQUEST, request)
      end

      def end_sync
        changed
        notify_observers(END_SYNC)
      end

      def begin_sync
        changed
        notify_observers(BEGIN_SYNC)
      end

    end
  end
end
