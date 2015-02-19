module InsalesAppCore
  module Synchronization
    module SyncMethods
      def safe_perform(&block)
        begin
          yield self
        rescue => ex
          changed
          notify_observers(::InsalesAppCore::Synchronization::Synchronizer::ERROR, ex, account_id)
          ::Rollbar.report_exception(ex)
        end
      end

      def sync(recent: true)
        safe_perform do
          begin_sync

          stage("Synchroniznig account #{@account.insales_subdomain}")

          ls = @account.collections_last_sync if recent
          sync_collections(ls)

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
        end
      end
    end
  end
end
