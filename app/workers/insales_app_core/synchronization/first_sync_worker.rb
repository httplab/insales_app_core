module InsalesAppCore::Synchronization
  class FirstSyncWorker
    include Sidekiq::Worker

    sidekiq_options queue: :first_sync_queue

    def perform(account_id)
      account = Account.find(account_id)
      account.configure_api
      synchronizer = Synchronizer.new(account_id, InsalesAppCore.config.sync_options)
      observers = InsalesAppCore.config.sync_observers_classes
      syncronizer.add_observer(InsalesAppCore::Synchronization::Observers::Logger.new)
      observers.each { |clazz| syncronizer.add_observer(clazz.new) }
      syncronizer.sync(false)
    end
  end
end


