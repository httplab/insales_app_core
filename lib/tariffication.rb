require_relative 'tariffication/configuration'
require_relative 'tariffication/tariff_configuration'

module Tariffication
  mattr_reader :config

  def self.setup(&blk)
    @@config = Tariffication::Configuration.new(&blk)
  end
end
