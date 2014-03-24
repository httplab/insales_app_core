require('observer')

module InsalesAppCore
  module Synchronization
    module Synchronizer
      extend Observable

      ENTITY_CREATED = 0
      ENTITY_MODIFIED = 1
      ENTITY_DELETED = 2
      WILL_WAIT_FOR = 3
      ENTITY_INTACT = 4

      def self.safe_api_call(cooldown = 20, &block)
        begin
          yield
        rescue ActiveResource::ServerError => ex
          if ex.response.code == 503
            retry_after = ex.response['Retry-After']
            retry_after = retry_after.present? ? retry_after.to_i : cooldown
            changed
            notify_observers(WILL_WAIT_FOR, retry_after)
            sleep(retry_after)
            retry
          else
            raise ex
          end
        end
      end

      def self.all_accounts(&block)
        Account.all.each do |acc|
          acc.configure_api
          yield acc
        end
      end

      def self.sync_all_accounts
        all_accounts do |acc|
          sync_all(acc.id)
        end
      end

      def self.sync_all(account_id)
        sync_categories(account_id)
        sync_products(account_id)
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

      def self.sync_products(account_id)
        page = 1
        remote_ids = []
        category_map = Category.ids_map

        while true do

          page_result = safe_api_call{InsalesApi::Product.find(:all, params: {per_page: 250, page: page})}

          # https://github.com/rails/activeresource/commit/c665bf3c7ccc834017a2168ee3c8a68a622b70e6
          # Пока это не попадет в релиз, придется использовать to_a
          break if page_result.to_a.empty?
          page += 1
          remote_ids += page_result.map(&:id)

          page_result.each do |remote_product|
            category_id = category_map[remote_product.category_id]
            next if category_id.nil?
            local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id, category_id: category_id)
            update_event(local_product)
            local_product.save!
            sync_variants(account_id, remote_product, local_product)
            sync_images(account_id, remote_product, local_product)
          end
        end

        unless remote_ids.empty?
          deleted = Product.where('account_id = ? AND insales_id NOT IN (?)', account_id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.sync_variants(account_id, remote_product, local_product)

        remote_variants = remote_product.variants

        remote_variants.each do |remote_variant|
          begin
          local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, product_id: local_product.id)
          local_variant.insales_product_id ||= remote_variant.id
          update_event(local_variant)
          local_variant.save!
          rescue => ex
            puts ex.message
            puts remote_variant.inspect
            break
          end
        end

        remote_ids = remote_variants.map(&:id)

        if remote_ids.any?
          deleted = Variant.where('account_id = ? AND product_id = ? AND insales_id NOT IN (?)', account_id, local_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end


      def self.sync_images(account_id, insales_product, local_product)
        remote_images = insales_product.images

        remote_images.each do |remote_image|
          begin
          local_image = Product::Image.update_or_create_by_insales_entity(remote_image, account_id: account_id, product_id: local_product.id)
          local_image.insales_product_id ||= insales_product.id
          update_event(local_image)
          local_image.save!
          rescue => ex
            puts ex.message
            puts remote_image.inspect
            break
          end
        end

        remote_ids = remote_images.map(&:id)

        if remote_ids.any?
          deleted = Product::Image.where('account_id = ? AND product_id = ? AND insales_id NOT IN (?)', account_id, local_product.id, remote_ids).delete_all
          changed
          notify_observers(ENTITY_DELETED, deleted)
        end
      end

      def self.update_event(entity)
        changed
        if entity.new_record? || entity.changed?
          notify_observers(entity.new_record? ? ENTITY_CREATED : ENTITY_MODIFIED, entity)
        else
          notify_observers(ENTITY_INTACT, entity)
        end
      end

    end
  end
end
