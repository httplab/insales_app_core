require('colorize')

class CoreSyncObserver

  def self.update(type, *args)
    case type
    when ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_CREATED
      print '+'.green
    when ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_MODIFIED
      print '~'.yellow
    when ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_DELETED
      if args[0].kind_of?(Numeric)
        args[0].times do
          print '-'.red
        end
      else
        print '-'.red
      end
    when ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_INTACT
      print '.'
    when ::InsalesAppCore::Synchronization::Synchronizer::WILL_WAIT_FOR
      print "*#{args[0]}*".red
    when ::InsalesAppCore::Synchronization::Synchronizer::STAGE
      puts
      puts args[0]
    when ::InsalesAppCore::Synchronization::Synchronizer::END_SYNC
      puts 'Synchronization completed'
    when ::InsalesAppCore::Synchronization::Synchronizer::REQUEST
      print 'R'.blue
    when ::InsalesAppCore::Synchronization::Synchronizer::BEGIN_SYNC
      system('clear')
    end
  end
end

namespace :insales_sync do
  desc 'Synchronize all Insales entities for all accounts'
  task all: :environment do
    prevent_multiple_executions do
      ::InsalesAppCore::Synchronization::Synchronizer.sync_all_accounts
    end
  end

  desc 'Synchronize all recently modified Insales entities for all accounts'
  task all_recent: :environment do
    prevent_multiple_executions do
      syncronizer = ::InsalesAppCore::Synchronization::Synchronizer.new
      syncronizer.add_observer(CoreSyncObserver)
      syncronizer.sync_all_accounts_recent
    end
  end

  desc 'Synchronize all recently modified Insales orders for all accounts'
  task orders_recent: :environment do
    prevent_multiple_executions do
      ::InsalesAppCore::Synchronization::Synchronizer.sync_recent_orders
    end
  end

  desc 'Synchronize all recently modified Insales products for all accounts'
  task products_recent: :environment do
    prevent_multiple_executions do
      ::InsalesAppCore::Synchronization::Synchronizer.sync_recent_products
    end
  end

  desc 'Synchronize all Insales orders for all accounts'
  task orders: :environment do
    prevent_multiple_executions do
      ::InsalesAppCore::Synchronization::Synchronizer.sync_all_orders
    end
  end
end
