require('parallel')
require('colorize')

namespace :insales_sync do
  desc 'Synchronize everything for all accounts'
  task all: :environment do
    prevent_multiple_executions do
      observers = InsalesAppCore.config.sync_observers_classes

      Parallel.each(Account.where(deleted: false), in_threads: 4) do |a|
        ActiveRecord::Base.connection_pool.with_connection do
          a.configure_api
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id, sync: InsalesAppCore.config.sync_options)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
          observers.each { |clazz| syncronizer.add_observer(clazz.new) }
          syncronizer.sync_all
        end
      end
    end
  end


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
          syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id, sync: InsalesAppCore.config.sync_options)
          syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
          observers.each { |clazz| syncronizer.add_observer(clazz.new) }
          syncronizer.resync_all_products
        end
      end
    end
  end

  desc 'Re-sync all products for given account'
  task :account_products, [:account_id] => :environment do |t, args|
    prevent_multiple_executions do
      puts args
      a = Account.find(args[:account_id].to_i)
      observers = InsalesAppCore.config.sync_observers_classes
      a.configure_api
      syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new(a.id, sync: InsalesAppCore.config.sync_options)
      syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new(true))
      observers.each { |clazz| syncronizer.add_observer(clazz.new) }
      syncronizer.resync_all_products
    end
  end
end
