module InsalesAppCore
  module Synchronization
    module SyncMethods
      def sync(recent: true)
        begin_sync
        stage("Synchroniznig account #{@account.insales_subdomain}")
        sync_collections
        sync_categories
        sync_properties

        ls = @account.products_last_sync if recent
        @account.products_last_sync = DateTime.now
        sync_products(ls)

        @account.save!
        sync_collects
        sync_fields

        ls = @account.clients_last_sync if recent
        @account.clients_last_sync = DateTime.now
        sync_clients(ls)

        ls = @account.orders_last_sync if recent
        @account.orders_last_sync = DateTime.now
        sync_orders(ls)
        @account.save!
        end_sync
      end
    end
  end
end
