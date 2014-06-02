module Tariffication
  class TariffConfiguration
    attr_reader :data,
                :limit_actions,
                :free_actions

    attr_accessor :title,
                  :description,
                  :url,
                  :image_url,
                  :base_price,
                  :name,
                  :classname


    def initialize(&block)
      @limit_actions = {}
      @free_actions = []
      self.classname = 'Tariffication::Processor'
      block.call(self) if block_given?
    end

    def initial_data(val = {})
      @data = val
    end

    def instance(account_id)
      klass = Object.const_get(@classname)
      klass.new(account_id, self)
    end

    def limit_action(name, limit)
      @limit_actions[name] = limit
    end

    def free_action(name)
      @free_actions << name
    end

  end
end
