require 'active_resource'

module InsalesAppCore
  module Synchronization
    module SyncMethods
      SKIP_ROLLBAR_EXCEPTIONS = [::ActiveResource::UnauthorizedAccess]

      def safe_perform(&block)
        yield self
      rescue => ex
        changed
        notify_observers(::InsalesAppCore::Synchronization::Synchronizer::ERROR, ex, account_id)

        unless SKIP_ROLLBAR_EXCEPTIONS.any? {|klass| ex.is_a? klass}
          ::Rollbar.report_exception(ex)
        end
      end

      def sync(recent: true)
        safe_perform do
          begin_sync

          stage("Synchroniznig account #{@account.insales_subdomain}")

          ls = @account.collections_last_sync if recent
          sync_collections(ls)

          sync_domains
          sync_categories
          sync_properties
          sync_product_fields

          ls = @account.products_last_sync if recent
          sync_products(ls)

          sync_collects
          sync_fields
          sync_client_groups

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
