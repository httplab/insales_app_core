require('parallel')
require('colorize')

namespace :insales_sync do
  desc 'Synchronize all recently modified Insales entities for all accounts'
  task all_recent: :environment do
    prevent_multiple_executions do
      observers = InsalesAppCore.config.sync_observers_classes

      Parallel.each(Account.for_sync, in_threads: 4) do |a|
        ActiveRecord::Base.connection_pool.with_connection do
          a.configure_api
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id, sync: InsalesAppCore.config.sync_options)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
          observers.each { |clazz| syncronizer.add_observer(clazz.new) }
          syncronizer.sync(recent: true)
        end
      end
    end
  end

  desc 'Delete all deleted products and orders'
  task sync_deleted_orders_and_products: :environment do
    prevent_multiple_executions do
      Parallel.each(Account.for_sync, in_threads: 4) do |a|
        ActiveRecord::Base.connection_pool.with_connection do
          a.configure_api
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id, sync: InsalesAppCore.config.sync_options)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))

          syncronizer.safe_perform do |s|
            s.delete_remotely_deleted_orders
            s.delete_remotely_deleted_products
          end
        end
      end
    end
  end
end
