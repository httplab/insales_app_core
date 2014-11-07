module InsalesAppCore
  module Synchronization
    module SyncMethods

      def resync_all_products
        begin_sync
        stage("Synchroniznig account #{@account.insales_subdomain}")
        sync_categories
        sync_properties
        @account.products_last_sync = DateTime.now
        sync_products
        @account.save!
        end_sync
      end

      def sync_all
        puts @sync_options
        begin_sync
        stage("Synchroniznig account #{@account.insales_subdomain}")
        sync_collections
        sync_categories
        sync_properties
        @account.products_last_sync = DateTime.now
        sync_products
        @account.save!
        sync_collects
        sync_fields
        @account.clients_last_sync = DateTime.now
        sync_clients
        @account.orders_last_sync = DateTime.now
        sync_orders
        @account.save!
        end_sync
      end

      def sync_all_recent
        begin_sync
        stage("Synchroniznig account #{@account.insales_subdomain}")
        sync_collections
        sync_categories
        sync_properties
        ls = @account.products_last_sync
        @account.products_last_sync = DateTime.now
        sync_products(ls)
        @account.save!
        sync_collects
        sync_fields
        ls = @account.clients_last_sync
        @account.clients_last_sync = DateTime.now
        sync_clients(ls)
        ls = @account.orders_last_sync
        @account.orders_last_sync = DateTime.now
        sync_orders(ls)
        @account.save!
        end_sync
      end
    end
  end
end
