module Tariffication
  class Configuration
    attr_accessor :tariffs

    def initialize(&block)
      @tariffs = {}
      block.call(self) if block_given?
    end

    def add_tariff(&block)
      t = Tariffication::TariffConfiguration.new(&block)
      @tariffs[t.name] = t
    end

    def [](name)
      @tariffs[name] if name.present?
    end

  end
end
