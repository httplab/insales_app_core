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
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
          observers.each { |clazz| syncronizer.add_observer(clazz.new) }
          syncronizer.sync_all_recent
        end
      end
    end
  end

  desc 'Re-sync all products for all accounts'
  task resync_all_products: :environment do
    prevent_multiple_executions do
      observers = InsalesAppCore.config.sync_observers_classes

      Parallel.each(Account.for_sync, in_threads: 4) do |a|
        ActiveRecord::Base.connection_pool.with_connection do
          a.configure_api
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
          observers.each { |clazz| syncronizer.add_observer(clazz.new) }
          syncronizer.resync_all_products
        end
      end
    end
  end
end
