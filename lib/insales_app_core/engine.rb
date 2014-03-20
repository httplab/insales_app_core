require 'has_scope'
require 'insales_api'
require 'active_link_to'
require 'slim-rails'

module InsalesAppCore
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework false
    end

    config.to_prepare do
      ActiveSupport.on_load :action_controller do
        ApplicationController.send :include, ControllerExtensions::Authorization
      end
    end
  end
end
