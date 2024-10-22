require 'observer'
require_relative 'sync_methods'

module InsalesAppCore
  module Synchronization
    class Synchronizer < Struct.new(:account_id)
      include Observable
      include ::InsalesAppCore::Synchronization::SyncMethods

      ENTITY_INTACT        =  0
      ENTITY_CREATED       =  1
      ENTITY_MODIFIED      =  2
      ENTITY_DELETED       =  3
      WILL_WAIT_FOR        =  4
      STAGE                =  5
      END_SYNC             =  6
      REQUEST              =  7
      BEGIN_SYNC           =  8
      ERROR                =  9
      ENTITY_AFTER_CREATE  = 10
      ENTITY_AFTER_UPDATE  = 11

      DEFAULT_SYNC_OPTIONS = {
        categories:              false,
        collections:             false,
        collects:                false,
        products:                false,
        images:                  false,
        variants:                false,
        fields:                  false,
        fields_values:           false,
        properties:              false,
        characteristics:         false,
        orders:                  false,
        order_lines:             false,
        shipping_addresses:      false,
        clients:                 false,
        client_groups:           false,
        product_fields:          false,
        product_field_values:    false,
        domains:                 false,
        option_names:            false,
        option_values:           false
      }

      def initialize(account_id, options = {})
        super(account_id)
        @account = Account.find(account_id)
        normalize_sync_options(options[:sync])
      end

      def safe_api_call(&block)
        callback = Proc.new do |wait_for|
          changed
          notify_observers(WILL_WAIT_FOR, wait_for, account_id)
        end

        begin
          InsalesApi.wait_retry(nil, callback, &block)
        rescue Zlib::BufError => ex
          changed
          notify_observers(ERROR, ex, account_id)
          retry
        end
      end

      def sync_domains
        return unless @sync_options[:domains]
        stage("Synchroniznig domains #{@account.insales_subdomain}")
        remote_domains = safe_api_call{InsalesApi::Domain.all}

        remote_domains.each do |remote_domain|
          local_domain = Domain.update_or_create_by_insales_entity(remote_domain, account_id: account_id)
          update_event(local_domain, remote_domain) do
            local_domain.save!(validate: false)
          end
        end


        remote_domains_ids = remote_domains.map(&:id)
        deleted = @account.domains.where.not(insales_id: remote_domains_ids).delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_categories
        return unless @sync_options[:categories]
        stage("Synchroniznig categories #{@account.insales_subdomain}")
        remote_categories = safe_api_call{InsalesApi::Category.all}

        remote_categories.each do |remote_category|
          local_category = Category.update_or_create_by_insales_entity(remote_category, account_id: account_id)

          update_event(local_category, remote_category) do
            local_category.save!(validate: false)
          end
        end

        local_categories = Category.where(account_id: account_id)
        remote_categories_ids = remote_categories.map(&:id)

        local_categories.each do |local_category|
          unless remote_categories_ids.include?(local_category.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_category, nil, account_id)
            local_category.delete
            next
          end
        end
      end

      def sync_client_groups
        return unless @sync_options[:client_groups]
        stage("Synchroniznig client_groups #{@account.insales_subdomain}")
        remote_client_groups = safe_api_call{InsalesApi::ClientGroup.all}

        remote_client_groups.each do |remote_client_group|
          local_client_group = ClientGroup.update_or_create_by_insales_entity(remote_client_group, account_id: account_id)

          update_event(local_client_group, remote_client_group) do
            local_client_group.save!(validate: false)
          end
        end

        remote_client_group_ids = remote_client_groups.map(&:id)
        local_client_groups_to_delete = @account.client_groups
          .where
          .not(insales_id: remote_client_group_ids)

        deleted = local_client_groups_to_delete.delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_properties
        return unless @sync_options[:properties]
        stage("Synchroniznig properties #{@account.insales_subdomain}")
        remote_ids = []
        remote_properties = safe_api_call{InsalesApi::Property.all}
        remote_properties.each do |remote_property|
          begin
            remote_ids << remote_property.id
            local_property = Property.update_or_create_by_insales_entity(remote_property, account_id: account_id)

            update_event(local_property, remote_property) do
              local_property.save!(validate: false)
            end

            sync_characteristics(remote_property, local_property)
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

      def sync_characteristics(remote_property, local_property)
        return unless @sync_options[:characteristics]

        remote_property.characteristics.each do |remote_characteristic|
          local_characteristic = Characteristic.update_or_create_by_insales_entity(remote_characteristic, insales_property_id: remote_property.id, account_id: account_id)

          update_event(local_characteristic, remote_characteristic) do
            local_characteristic.save!(validate: false)
          end
        end

        remote_ids = remote_property.characteristics.map(&:id)
        local_property.characteristics.where.not(insales_id: remote_ids).delete_all
      end

      def sync_product_fields
        return unless @sync_options[:product_fields]
        report_stage('product fields')

        remote_product_fields = safe_api_call{InsalesApi::ProductField.all}

        remote_product_fields.each do |remote_product_field|
          local_product_field = ProductField.update_or_create_by_insales_entity(remote_product_field, account_id: account_id)

          update_event(local_product_field, remote_product_field) do
            local_product_field.save!(validate: false)
          end
        end

        remote_product_fields_ids = remote_product_fields.map(&:id)

        deleted = @account.product_fields.where.not(insales_id: remote_product_fields_ids).delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_products(updated_since = nil)
        return unless @sync_options[:products]
        @account.products_last_sync = DateTime.now

        report_stage('products', updated_since)

        @characteristics_cache = nil
        remote_ids = []

        get_paged(InsalesApi::Product, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_product|
            begin
              local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id)

              update_event(local_product, remote_product) do
                local_product.save!(validate: false)
              end

              sync_variants(remote_product)
              sync_images(remote_product)
              sync_product_characteristics(remote_product, local_product)
              sync_product_field_values(remote_product)
            rescue => ex
              changed
              notify_observers(ERROR, ex, local_product, account_id)
            end
          end
        end

        delete_remotely_deleted_products(remote_ids, updated_since)
        @account.save!
      end

      def delete_remotely_deleted_products(present_ids = nil, updated_since = nil, force_use_present = false)
        stage("Synchroniznig deleted products for #{@account.insales_subdomain} (since #{updated_since})")

        present_ids ||= get_paged(InsalesApi::Product, 250).map(&:id) if force_use_present

        if updated_since || present_ids.nil?
          remote_ids = []

          get_paged(InsalesApi::Product, 250, updated_since: updated_since, deleted: true) do |page_result|
            remote_ids += page_result.map(&:id)
          end

          # puts "#{remote_ids.inspect}, #{@account.insales_subdomain}".red
        else
          remote_ids = @account.products.where('insales_id NOT IN (?)', present_ids).pluck(:insales_id)
        end

        if remote_ids.any?
          deleted = Product.where('account_id = ? AND insales_id IN (?)', account_id, remote_ids).delete_all
          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, nil, account_id)
          end
        end
      end

      def sync_product_field_values(remote_product)
        return unless @sync_options[:product_field_values]

        remote_product_field_values = remote_product.product_field_values
        remote_product_field_values_ids = remote_product_field_values.map(&:id)

        deleted = ProductFieldValue
          .where(insales_product_id: remote_product.id)
          .where.not(insales_id: remote_product_field_values_ids)
          .delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end

        remote_product_field_values.each do |rpfv|
          begin
            lpfv = ProductFieldValue.update_or_create_by_insales_entity(rpfv, insales_product_id: remote_product.id)

            update_event(lpfv, rpfv) do
              lpfv.save!(validate: false)
            end
          rescue
            p rpfv
            p lpfv
            raise
          end
        end
      end

      def sync_variants(remote_product)
        return unless @sync_options[:variants]
        remote_variants = remote_product.variants
        remote_ids = remote_variants.map(&:id)

        if remote_ids.any?
          deleted = Variant.where('account_id = ? AND insales_product_id = ? AND insales_id NOT IN (?)', account_id, remote_product.id, remote_ids).delete_all

          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, nil, account_id)
          end
        end

        remote_variants.each do |remote_variant|
          begin
            local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, insales_product_id: remote_product.id)

            update_event(local_variant, remote_variant) do
              local_variant.save!(validate: false)
            end
          rescue => ex
            puts ex.message
            puts ex.backtrace
            puts remote_variant.inspect
          end
        end
      end

      def sync_images(remote_product)
        return unless @sync_options[:images]
        remote_images = remote_product.images

        remote_images.each do |remote_image|
          begin
            local_image = Image.update_or_create_by_insales_entity(remote_image, account_id: account_id, insales_product_id: remote_product.id)

            update_event(local_image, remote_image) do
              local_image.save!(validate: false)
            end
          rescue => ex
            puts ex.message
            puts remote_image.inspect
          end
        end

        remote_ids = remote_images.map(&:id)

        if remote_ids.any?
          deleted = Image.where('account_id = ? AND insales_product_id = ? AND insales_id NOT IN (?)', account_id, remote_product.id, remote_ids).delete_all

          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, nil, account_id)
          end
        end
      end

      def sync_product_characteristics(remote_product, local_product)
        return unless @sync_options[:characteristics]

        @characteristics_cache ||= {}
        product_characteristics_ids = []

        remote_product.characteristics.each do |remote_characteristic|
          begin
            local_characteristic = @characteristics_cache[remote_characteristic.id]

            if local_characteristic.nil?
              local_characteristic =
                Characteristic.update_or_create_by_insales_entity(
                  remote_characteristic,
                  account_id: account_id,
                  insales_property_id: remote_characteristic.prefix_options[:property_id]
                )
              @characteristics_cache[remote_characteristic.id] = local_characteristic

              update_event(local_characteristic, remote_characteristic) do
                local_characteristic.save!(validate: false)
              end
            end

            product_characteristics_ids << local_characteristic.id
          rescue => ex
            puts ex.message
            p remote_characteristic
            p local_characteristic if local_characteristic
          end
        end

        local_product.characteristic_ids = product_characteristics_ids
      end

      def sync_fields
        return unless @sync_options[:fields]
        stage("Synchroniznig fields #{@account.insales_subdomain}")
        remote_fields = safe_api_call{InsalesApi::Field.all}
        remote_ids = remote_fields.map(&:id)
        remote_fields.each do |remote_field|
          local_field = Field.update_or_create_by_insales_entity(remote_field, account_id: account_id)

          update_event(local_field, remote_field) do
            local_field.save!(validate: false)
          end
        end

        if remote_ids.any?
          deleted = Field.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_orders(updated_since = nil)
        return unless @sync_options[:orders]
        @account.orders_last_sync = DateTime.now
        remote_ids = []
        report_stage('orders', updated_since)
        get_paged(InsalesApi::Order, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_order|
            sync_one_order(remote_order)
          end
        end

        delete_remotely_deleted_orders(remote_ids, updated_since)
        @account.save!
      end

      def delete_remotely_deleted_orders(present_ids = nil, updated_since = nil)
        stage("Synchroniznig deleted orders for #{@account.insales_subdomain} (since #{updated_since})")

        if updated_since || present_ids.nil?
          remote_ids = []

          get_paged(InsalesApi::Order, 250, updated_since: updated_since, deleted: true) do |page_result|
            remote_ids += page_result.map(&:id)
          end
        else
          remote_ids = @account.orders.where('insales_id NOT IN (?)', present_ids).pluck(:insales_id)
        end

        if remote_ids.any?
          deleted = Order.where('account_id = ? AND insales_id IN (?)', account_id, remote_ids).delete_all
          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, nil, account_id)
          end
        end
      end

      def sync_one_order(remote_order)
        local_order = Order.update_or_create_by_insales_entity(remote_order, account_id: account_id, insales_client_id: remote_order.client.id)

        if @sync_options[:clients]
          client = Client.find_by(insales_id: local_order.insales_client_id) || sync_one_client(local_order.insales_client_id)

          unless client
            fail "sync_one_order: Client with insales_client_id=#{local_order.insales_client_id} not found in database"
          end
        end

        if remote_order.respond_to?(:cookies) && remote_order.cookies.present?
          local_order.cookies = remote_order.cookies.attributes
        end

        update_event(local_order, remote_order) do
          local_order.save!(validate: false)
        end

        sync_fields_values(remote_order.fields_values, remote_order.id)
        sync_order_lines(remote_order.order_lines, remote_order.id)
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
        return unless @sync_options[:fields_values]
        remote_ids = remote_fields_values.map(&:id)
        remote_fields_values.each do |remote_fields_value|
          # Если в value содержится экземпляр класса InsalesApi::Order::FieldsValue::Value,
          # приводим его к строке
          value = remote_fields_value.value
          value = value.to_json unless value.is_a?(String)

          local_fields_value = FieldsValue.update_or_create_by_insales_entity(remote_fields_value,
            account_id: account_id, value: value, insales_owner_id: insales_owner_id)

          update_event(local_fields_value, remote_fields_value) do
            local_fields_value.save!(validate: false)
          end
        end

        if remote_ids.any?
          deleted = FieldsValue.where('account_id = ? AND insales_owner_id = ? AND insales_id NOT IN (?)',
           account_id, insales_owner_id, remote_ids).delete_all

          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, account_id)
          end
        end
      end

      def sync_order_lines(remote_order_lines, insales_order_id)
        return unless @sync_options[:order_lines]
        remote_ids = remote_order_lines.map(&:id)

        remote_order_lines.each do |remote_order_line|
          begin
            local_order_line = OrderLine.update_or_create_by_insales_entity(remote_order_line,
              account_id: account_id, insales_order_id: insales_order_id)

            update_event(local_order_line, remote_order_line)do
              local_order_line.save!(validate: false)
            end
          rescue => ex
            changed
            notify_observers(ERROR, ex, account_id)
          end
        end

        if remote_ids.any?
          deleted = OrderLine.where('account_id = ? AND insales_order_id =? AND insales_id NOT in (?)',
            account_id, insales_order_id, remote_ids).delete_all
          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, account_id)
          end
        end
      end

      def sync_order_shipping_address(remote_shipping_address, insales_order_id)
        return unless @sync_options[:shipping_addresses]
        sa = Order::ShippingAddress.update_or_create_by_insales_entity(remote_shipping_address,
          account_id: account_id, insales_order_id: insales_order_id)
        sa.save!(validate: false)
      end

      def sync_clients(updated_since = nil)
        return unless @sync_options[:clients]
        @account.clients_last_sync = DateTime.now
        report_stage('clients', updated_since)
        remote_ids = []

        get_paged(InsalesApi::Client, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)
          page_result.each do |remote_client|
            sync_one_client(remote_client)
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Client.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          if deleted > 0
            changed
            notify_observers(ENTITY_DELETED, deleted, account_id)
          end
        end

        @account.save!
      end

      def sync_one_client(remote_client)
        unless remote_client.is_a? InsalesApi::Client
          remote_client = InsalesApi::Client.find(remote_client)
        end

        local_client = Client.update_or_create_by_insales_entity(remote_client, account_id: account_id)

        update_event(local_client, remote_client) do
          local_client.save!(validate: false)
        end

        sync_fields_values(remote_client.fields_values, remote_client.id)
        local_client
      rescue => ex
        puts ex.message
        puts ex.backtrace
        p local_client
        p local_client.attributes
      end

      def sync_collections(updated_since = nil)
        return unless @sync_options[:collections]
        @account.collections_last_sync = DateTime.now

        report_stage('collections', updated_since)
        remote_collections = safe_api_call{InsalesApi::Collection.all(params:{updated_since: updated_since})}

        remote_collections.each do |remote_collection|
          local_collection = Collection.update_or_create_by_insales_entity(remote_collection, account_id: account_id)

          update_event(local_collection) do
            local_collection.save!(validate: false)
          end
        end

        if updated_since.nil?
          local_collections = Collection.where(account_id: account_id)
          remote_collections_ids = Set.new(remote_collections.map(&:id))

          local_collections.each do |local_collection|
            unless remote_collections_ids.include?(local_collection.insales_id)
              changed
              notify_observers(ENTITY_DELETED, local_collection, account_id)
              local_collection.delete
              next
            end
          end
        end

        @account.save
      end

      def sync_collects
        return unless @sync_options[:collects]
        stage("Synchroniznig collects #{@account.insales_subdomain}")
        remote_pairs = []

        get_paged(InsalesApi::Collect, 1000) do |page_result|
          page_result.each do |c|
            remote_pairs << [c.collection_id, c.product_id]
          end
        end

        local_pairs = Collect.where('account_id = ?', account_id).pluck(:insales_collection_id, :insales_product_id)

        pairs_to_delete = local_pairs - remote_pairs
        pairs_to_delete = pairs_to_delete.map {|p| "(#{p[0]}, #{p[1]})"}.join(',')
        collects_to_delete = Collect.where("(insales_collection_id, insales_product_id) IN (#{pairs_to_delete})")
        collects_to_delete.delete_all if pairs_to_delete.present?
        pairs_to_create = remote_pairs - local_pairs
        values_clause = pairs_to_create.map {|v| "(#{v[0]},#{v[1]},#{account_id})"}.join(',')

        if pairs_to_create.any?
          Collect.connection.execute("INSERT INTO collects (insales_collection_id, insales_product_id, account_id) VALUES #{values_clause}")
        end
      end

      def sync_option_names
        return unless @sync_options[:option_names]
        report_stage('option names')

        remote_option_names = safe_api_call{InsalesApi::OptionName.all}

        remote_option_names.each do |remote_option_name|
          local_option_name = OptionName.update_or_create_by_insales_entity(remote_option_name, account_id: account_id)
          update_event(local_option_name, remote_option_name) do
            local_option_name.save!(validate: false)
          end
        end

        remote_option_names_ids = remote_option_names.map(&:id)

        deleted = @account.option_names.where.not(insales_id: remote_option_names_ids).delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      def sync_option_values
        return unless @sync_options[:option_values]
        report_stage('option values')

        remote_option_values = safe_api_call{InsalesApi::OptionValue.all}

        remote_option_values.each do |remote_option_value|
          local_option_value = OptionValue.update_or_create_by_insales_entity(remote_option_value, account_id: account_id)
          update_event(local_option_value, remote_option_value) do
            local_option_value.save!(validate: false)
          end
        end

        remote_option_values_ids = remote_option_values.map(&:id)

        deleted = @account.option_values.where.not(insales_id: remote_option_values_ids).delete_all

        if deleted > 0
          changed
          notify_observers(ENTITY_DELETED, deleted, nil, account_id)
        end
      end

      # Постраничное получение сущностей
      def get_paged(type, page_size = nil, addl_params = {})
        page = 1
        res = []
        while true do

          params = {
            page: page
          }
          params[:per_page] = page_size unless page_size.nil?
          addl_params.delete_if{|k,v| v.nil?}
          params.merge!(addl_params)
          page_result = safe_api_call{type.find(:all, params: params)}

          # https://github.com/rails/activeresource/commit/c665bf3c7ccc834017a2168ee3c8a68a622b70e6
          # Пока это не попадет в релиз, придется использовать to_a
          return res if page_result.to_a.empty?
          yield page_result if block_given?
          page += 1
          res += page_result.to_a
        end
      end

      # Методы для оповещения наблюдателей
      def update_event(entity, remote_entity = nil)
        changed
        changes = {}

        if entity.new_record? || entity.changed?
          type = entity.new_record? ? ENTITY_CREATED : ENTITY_MODIFIED
          changes = entity.changes.clone
        else
          type = ENTITY_INTACT
        end

        notify_observers(type, entity, remote_entity, changes, account_id)

        res = yield if block_given?

        return unless res

        case type
        when ENTITY_MODIFIED
          changed
          notify_observers(ENTITY_AFTER_UPDATE, entity, remote_entity, changes, account_id)
        when ENTITY_CREATED
          changed
          notify_observers(ENTITY_AFTER_CREATE, entity, remote_entity, changes, account_id)
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
      end

      def report_stage(entity, updated_since = nil)
        if updated_since.present?
          stage("Synchroniznig #{entity} for #{@account.insales_subdomain} (since #{updated_since})")
        else
          stage("Synchroniznig #{entity} for #{@account.insales_subdomain}")
        end
      end
    end
  end
end
