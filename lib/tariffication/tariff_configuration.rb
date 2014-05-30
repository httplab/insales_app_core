module Tariffication
  class TariffConfiguration
    attr_reader :data

    attr_accessor :title,
                  :description,
                  :url,
                  :image_url,
                  :base_price,
                  :name,
                  :classname


    def initialize(&block)
      block.call(self) if block_given?
    end

    def initial_data(val = {})
      @data = val
    end

  end
end
