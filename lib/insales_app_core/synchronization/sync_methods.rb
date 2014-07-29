module InsalesAppCore
  module Synchronization
    module SyncMethods

      def all_accounts(&block)
        Account.all.each do |acc|
          acc.configure_api
          yield acc
        end
      end

      def sync_all_accounts
        begin_sync

        all_accounts do |acc|
          sync_all(acc)
        end

        end_sync
      end

      def sync_all_accounts_recent
        begin_sync

        all_accounts do |acc|
          sync_all_recent(acc)
        end

        end_sync
      end

      def sync_all(acc)
        stage("Synchroniznig account #{acc.insales_subdomain}")
        stage('Synchroniznig categories')
        sync_categories(acc.id)
        stage('Synchroniznig products')

        acc.products_last_sync = DateTime.now
        sync_products(acc.id)
        acc.save!

        stage('Synchroniznig fields')
        sync_fields(acc.id)

        stage('Synchroniznig clients')
        acc.clients_last_sync = DateTime.now
        sync_clients(acc.id)

        stage('Synchroniznig orders')
        acc.orders_last_sync = DateTime.now
        sync_orders(acc.id)
        acc.save!
      end

      def sync_all_recent(acc)
        stage("Synchroniznig account #{acc.insales_subdomain}")
        stage('Synchroniznig categories')
        sync_categories(acc.id)
        stage('Synchroniznig recent products')
        ls = acc.products_last_sync
        acc.products_last_sync = DateTime.now
        sync_products(acc.id, ls)
        acc.save!

        stage('Synchroniznig fields')
        sync_fields(acc.id)

        stage('Synchroniznig clients')
        ls = acc.clients_last_sync
        acc.clients_last_sync = DateTime.now
        sync_clients(acc.id)

        stage('Synchroniznig recent orders')
        ls = acc.orders_last_sync
        acc.orders_last_sync = DateTime.now
        sync_orders(acc.id, ls)
        acc.save!
      end

      def sync_recent_orders
        begin_sync
        all_accounts do |acc|
          stage("Synchroniznig account #{acc.insales_subdomain}")
          stage('Synchroniznig fields')
          sync_fields(acc.id)

          stage('Synchroniznig orders')
          ls = acc.orders_last_sync
          acc.orders_last_sync = DateTime.now
          sync_orders(acc.id, ls)
          acc.save!
        end
        end_sync
      end

      def sync_all_orders
        begin_sync
        all_accounts do |acc|
          stage("Synchroniznig account #{acc.insales_subdomain}")
          stage('Synchroniznig fields')
          sync_fields(acc.id)

          stage('Synchroniznig orders')
          acc.orders_last_sync = DateTime.now
          sync_orders(acc.id)
          acc.save!
        end
        end_sync
      end

      def sync_recent_products
        begin_sync
        all_accounts do |acc|
          stage("Synchroniznig account #{acc.insales_subdomain}")
          stage('Synchroniznig categories')
          sync_categories(acc.id)
          stage('Synchroniznig products')

          acc.products_last_sync = DateTime.now
          sync_products(acc.id)
          acc.save!
        end
        end_sync
      end

    end
  end
end
