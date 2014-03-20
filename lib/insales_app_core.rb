require 'insales_app_core/controller_extensions/authorization'
require 'insales_app_core/engine'
require 'insales_app_core/configuration'

module InsalesAppCore
  mattr_accessor :config

  def self.setup(&blk)
    self.config = InsalesAppCore::Configuration.new(&blk)
  end
end
