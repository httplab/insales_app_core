module InsalesAppCore
  module Synchronization
    SYNC_OPTIONS_ENTITIES = [:orders, :products, :clients, :collections]

    def self.synced_entities
      InsalesAppCore.config.synced_entities
    end

    def self.entities_with_sync_options
      SYNC_OPTIONS_ENTITIES
    end

    def self.synced_entities_with_sync_options
      entities_with_sync_options & synced_entities.to_a
    end
  end
end
