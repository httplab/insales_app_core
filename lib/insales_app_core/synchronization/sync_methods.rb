module InsalesAppCore
  module Synchronization
    module SyncMethods
      def sync(recent: true)
        begin
          begin_sync

          stage("Synchroniznig account #{@account.insales_subdomain}")
          sync_collections
          sync_categories
          sync_properties

          ls = @account.products_last_sync if recent
          sync_products(ls)

          sync_collects
          sync_fields

          ls = @account.clients_last_sync if recent
          sync_clients(ls)

          ls = @account.orders_last_sync if recent
          sync_orders(ls)

          end_sync
        rescue => ex
          updated
          notify_observers(ERROR, ex, account_id)
        end
      end
    end
  end
end
