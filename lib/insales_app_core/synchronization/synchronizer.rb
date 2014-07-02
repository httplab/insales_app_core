require 'observer'
require_relative 'sync_methods'

module InsalesAppCore
  module Synchronization
    module Synchronizer
      extend Observable
      extend ::InsalesAppCore::Synchronization::SyncMethods

      ENTITY_INTACT = 0
      ENTITY_CREATED = 1
      ENTITY_MODIFIED = 2
      ENTITY_DELETED = 3
      WILL_WAIT_FOR = 4
      STAGE = 5
      END_SYNC = 6
      REQUEST = 7
      BEGIN_SYNC = 8

      def self.safe_api_call(&block)
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

      def self.sync_categories(account_id)
        remote_categories = safe_api_call{InsalesApi::Category.all}

        remote_categories.each do |remote_category|
          local_category = Category.update_or_create_by_insales_entity(remote_category, account_id: account_id)
          update_event(local_category)
          local_category.save!
        end

        local_categories = Category.where(account_id: account_id)
        remote_categories_ids = remote_categories.map(&:id)
        tree_map = Category.ids_map

        local_categories.each do |local_category|
          if !remote_categories_ids.include?(local_category.insales_id)
            changed
            notify_observers(ENTITY_DELETED, local_category)
            local_category.delete
            next
          end

          local_category.parent_id = tree_map[local_category.insales_parent_id]
          local_category.save!
        end
      end

      def self.sync_products(account_id, updated_since = nil)
        remote_ids = []
        @category_map ||= Category.ids_map

        get_paged(InsalesApi::Product, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)

          page_result.each do |remote_product|
            category_id = @category_map[remote_product.category_id]
            next if category_id.nil?
            begin
              local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id, category_id: category_id)
              update_event(local_product, remote_product)
              local_product.save!
              sync_variants(account_id, remote_product, local_product)
              sync_images(account_id, remote_product, local_product)
            rescue => ex
              puts ex.message
              if local_product
                p local_product
                p local_product.attributes
              end
              return
            end
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Product.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_variants(account_id, remote_product, local_product)
        remote_variants = remote_product.variants
        remote_ids = remote_variants.map(&:id)

        if remote_ids.any?
          deleted = Variant.where('account_id = ? AND product_id = ? AND insales_id NOT IN (?)', account_id, local_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end

        remote_variants.each do |remote_variant|
          begin
            local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, product_id: local_product.id)
            local_variant.insales_product_id ||= remote_product.id
            update_event(local_variant)
            local_variant.save!
          rescue => ex
            puts ex.message
            puts remote_variant.inspect
            next
          end
        end
      end

      def self.sync_images(account_id, insales_product, local_product)
        remote_images = insales_product.images

        remote_images.each do |remote_image|
          begin
            local_image = Image.update_or_create_by_insales_entity(remote_image, account_id: account_id, product_id: local_product.id)
            local_image.insales_product_id ||= insales_product.id
            update_event(local_image)
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
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_fields(account_id)
        remote_fields = safe_api_call{InsalesApi::Field.all}
        remote_ids = remote_fields.map(&:id)
        remote_fields.each do |remote_field|
          local_field = Field.update_or_create_by_insales_entity(remote_field, account_id: account_id)
          update_event(local_field)
          local_field.save!
        end

        if remote_ids.any?
          deleted = Field.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_orders(account_id, updated_since = nil)
        remote_ids = []
        puts updated_since
        get_paged(InsalesApi::Order, 250, updated_since: updated_since) do |page_result|
          remote_ids += page_result.map(&:id)

          page_result.each do |remote_order|
            begin
              local_order = Order.update_or_create_by_insales_entity(remote_order, account_id: account_id)

              if remote_order.cookies.present?
                local_order.cookies = remote_order.cookies.attributes
              end

              update_event(local_order)
              local_order.save!(:validate => false)
            rescue => ex
              puts ex.message
              puts ex.backtrace
              p local_order
              p local_order.attributes
              return
            end

            sync_fields_values(remote_order.fields_values, account_id, local_order.id)
            sync_order_lines(remote_order.order_lines, account_id, local_order.id, remote_order.id)
          end
        end

        if remote_ids.any? && updated_since.nil?
          deleted = Order.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_fields_values(remote_fields_values, account_id, owner_id)
        remote_ids = remote_fields_values.map(&:id)
        @fields_map ||= Field.ids_map

        remote_fields_values.each do |remote_fields_value|

          local_field_id = @fields_map[remote_fields_value.field_id.to_i]
          next if local_field_id.nil?
          local_fields_value = FieldsValue.update_or_create_by_insales_entity(remote_fields_value,
            account_id: account_id, owner_id: owner_id, field_id: local_field_id)
          update_event(local_fields_value)
          local_fields_value.save!(:validate => false)
        end

        if remote_ids.any?
          deleted = FieldsValue.where('account_id = ? AND owner_id = ? AND insales_id NOT IN (?)',
           account_id, owner_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_order_lines(remote_order_lines, account_id, order_id, insales_order_id)
        remote_ids = remote_order_lines.map(&:id)
        @products_map ||= Product.ids_map
        @variants_map ||= Variant.ids_map

        remote_order_lines.each do |remote_order_line|
          local_product_id = @products_map[remote_order_line.product_id.to_i]
          local_variant_id = @variants_map[remote_order_line.variant_id.to_i]
          next if local_product_id.nil? || local_variant_id.nil?
          local_order_line = OrderLine.update_or_create_by_insales_entity(remote_order_line,
            account_id: account_id, order_id: order_id, product_id: local_product_id,
            variant_id: local_variant_id, insales_order_id: insales_order_id)
          update_event(local_order_line)
          local_order_line.save!
        end

        if remote_ids.any?
          deleted = OrderLine.where('account_id = ? AND order_id =? AND insales_id NOT in (?)',
            account_id, order_id, remote_ids).delete_all
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      # Постраничное получение сущностей
      def self.get_paged(type, page_size = nil, addl_params = {})
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
      def self.update_event(entity, remote_entity = nil)
        changed
        if entity.new_record? || entity.changed?
          notify_observers(entity.new_record? ? ENTITY_CREATED : ENTITY_MODIFIED, entity, remote_entity)
        else
          notify_observers(ENTITY_INTACT, entity, remote_entity)
        end
      end

      def self.stage(stage)
        changed
        notify_observers(STAGE, stage)
      end

      def self.request(request)
        changed
        notify_observers(REQUEST, request)
      end

      def self.end_sync
        changed
        notify_observers(END_SYNC)
      end

      def self.begin_sync
        changed
        notify_observers(BEGIN_SYNC)
      end

    end
  end
end
