require 'insales_app_core/controller_extensions/authorization'
require 'insales_app_core/controller_extensions/styx'
require 'insales_app_core/model_extensions/insales_entity'
require 'insales_app_core/model_extensions/synced'
require 'insales_app_core/synchronization/synchronizer'
require 'insales_app_core/synchronization/observers/logger'
require 'insales_app_core/engine'
require 'insales_app_core/configuration'
require 'insales_app_core/app_menu/app_menu'
require 'insales_app_core/app_menu/menu_item'
require_relative 'tariffication'
require 'insales_app_core/account_setting'
require 'insales_app_core/account_setting/account_settings_collection'

module InsalesAppCore
  mattr_accessor :config

  def self.setup(&blk)
    self.config = InsalesAppCore::Configuration.new(&blk)
  end
end

