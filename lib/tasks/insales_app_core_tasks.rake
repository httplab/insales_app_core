# desc "Explaining what the task does"
# task :insales_app_core do
#   # Task goes here
# end

class SyncObserver

  def self.update(type, is_new, entity)
    puts "#{type} is #{is_new ? 'created' : 'updated'}; id: #{entity.id}, insales_id: #{entity.insales_id}"
  end

  ::InsalesAppCore::Synchronization::Synchronizer.add_observer(self)
end



namespace :insales_sync do



  desc 'Synchronize all Insales entities for all accounts'
  task all: :environment do
    ::InsalesAppCore::Synchronization::Synchronizer.sync_all_accounts
  end
end
