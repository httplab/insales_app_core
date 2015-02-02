require 'has_scope'
require 'insales_api'
require 'active_link_to'
require 'slim-rails'
require 'styx'
require 'responders'
require 'unicode'
require 'nokogiri'
require 'kaminari'
require 'bootstrap-kaminari-views'
require 'bootstrap-sass'
require 'high_voltage'
require 'sidekiq'


module InsalesAppCore
  autoload :TestHelpers, 'insales_app_core/test_helpers'

  class Engine < ::Rails::Engine
    config.generators do |g|
      g.stylesheet_engine = :scss
      g.javascript_engine = :coffee
      g.template_engine = :slim
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.to_prepare do

      ActiveSupport.on_load :action_controller do
        ApplicationController.send :include, ControllerExtensions::Authorization
        ApplicationController.send :include, ControllerExtensions::Styx
      end

      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send(:include, ModelExtensions::InsalesEntity)
      end

    end


  end
end
