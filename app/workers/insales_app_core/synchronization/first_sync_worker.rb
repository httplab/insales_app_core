module InsalesAppCore::Synchronization
  class FirstSyncWorker
    include Sidekiq::Worker

    sidekiq_options queue: :first_sync_queue

    def perform(account_id)
      account = Account.find(account_id)
      account.configure_api
      syncronizer = Synchronizer.new(account_id)

      observers = InsalesAppCore.config.sync_observers_classes
      syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new)
      observers.each { |clazz| syncronizer.add_observer(clazz.new) }
      syncronizer.sync_all
    end
  end
end


