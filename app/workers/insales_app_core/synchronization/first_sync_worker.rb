module InsalesAppCore::Synchronization
  class FirstSyncWorker
    include Sidekiq::Worker

    def perform(account_id)
      account = Account.find(account_id)
      account.configure_api
      syncronizer = Synchronizer.new
      syncronizer.sync_all(account)
    end
  end
end


