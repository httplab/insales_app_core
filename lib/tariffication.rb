require_relative 'tariffication/configuration'
require_relative 'tariffication/tariff_configuration'
require_relative 'tariffication/processor'
require_relative 'tariffication/insales_dependent_tariff'

module Tariffication
  mattr_reader :config

  def self.setup(&blk)
    @@config = Tariffication::Configuration.new(&blk)
  end

  def self.tariffs
    @@config.tariffs || []
  end
end
