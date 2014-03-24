require('observer')

module InsalesAppCore
  module Synchronization
    module Synchronizer
      extend Observable

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
        sync_variants(account_id)
      end

      def self.sync_categories(account_id)
        remote_categories = InsalesApi::Category.all

        remote_categories.each do |remote_category|
          local_category = Category.update_or_create_by_insales_entity(remote_category, account_id: account_id)
          update_event(local_category)
          local_category.save!
        end

        local_categories = Category.all
        remote_categories_ids = remote_categories.map(&:id)
        tree_map = Category.ids_map

        local_categories.each do |local_category|
          if !remote_categories_ids.include?(local_category.insales_id)
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
          puts "Page #{page}"
          page_result = InsalesApi::Product.find(:all, params: {per_page: 50, page: page})

          # https://github.com/rails/activeresource/commit/c665bf3c7ccc834017a2168ee3c8a68a622b70e6
          # Пока это не попадет в релиз, придется использовать to_a
          break if page_result.to_a.empty?
          page += 1
          remote_ids += page_result.map(&:id)

          page_result.each do |remote_product|
            category_id = category_map[remote_product.category_id]
            next if category_id.nil?
            local_product = Product.update_or_create_by_insales_entity(remote_product, account_id: account_id, category_id: category_id)
            local_product.save!
          end
        end

        unless remote_ids.empty?
          Product.where('insales_id NOT IN (?)', remote_ids).delete_all
        end
      end

      def self.sync_variants(account_id, product = nil)
        if product.nil?
          Product.where(account_id: account_id).each do |pr|
            sync_variants(account_id, pr)
          end
          return
        end

        remote_product = InsalesApi::Product.find(product.insales_id)

        return nil if remote_product.nil?
        remote_variants = remote_product.variants

        remote_variants.each do |remote_variant|
          begin
          local_variant = Variant.update_or_create_by_insales_entity(remote_variant, account_id: account_id, product_id: product.id)

          local_variant.insales_product_id ||= remote_variant.prefix_options[:product_id]

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
          Variant.where('product_id = ? AND insales_id NOT IN (?)', product.id, remote_ids).delete_all
        end
      end

      def self.update_event(entity)
        return unless entity.new_record? || entity.changed?
        changed
        notify_observers(entity.class.name, entity.new_record?, entity)
      end

    end
  end
end
