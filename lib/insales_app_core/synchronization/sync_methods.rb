module InsalesAppCore
  module Synchronization
    module SyncMethods
      def sync_all
        acc = Account.find(account_id)

        stage("Synchroniznig account #{acc.insales_subdomain}")

        stage("Synchroniznig collections #{acc.insales_subdomain}")
        sync_collections

        stage("Synchroniznig categories #{acc.insales_subdomain}")
        sync_categories

        stage("Synchroniznig products #{acc.insales_subdomain}")
        acc.products_last_sync = DateTime.now
        sync_products
        acc.save!

        stage("Synchroniznig fields #{acc.insales_subdomain}")
        sync_fields

        stage("Synchroniznig clients #{acc.insales_subdomain}")
        acc.clients_last_sync = DateTime.now
        sync_clients

        stage("Synchroniznig orders #{acc.insales_subdomain}")
        acc.orders_last_sync = DateTime.now
        sync_orders
        acc.save!
      end

      def sync_all_recent
        acc = Account.find(account_id)
        stage("Synchroniznig account #{acc.insales_subdomain}")

        stage("Synchroniznig collections #{acc.insales_subdomain}")
        sync_collections

        stage("Synchroniznig categories #{acc.insales_subdomain}")
        sync_categories

        stage("Synchroniznig recent products #{acc.insales_subdomain}")
        ls = acc.products_last_sync
        acc.products_last_sync = DateTime.now
        sync_products(ls)
        acc.save!

        stage("Synchroniznig fields #{acc.insales_subdomain}")
        sync_fields

        stage("Synchroniznig recent clients #{acc.insales_subdomain}")
        ls = acc.clients_last_sync
        acc.clients_last_sync = DateTime.now
        sync_clients(ls)

        stage("Synchroniznig recent orders #{acc.insales_subdomain}")
        ls = acc.orders_last_sync
        acc.orders_last_sync = DateTime.now
        sync_orders(ls)
        acc.save!
      end
    end
  end
end
