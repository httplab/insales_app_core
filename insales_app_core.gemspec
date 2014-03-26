$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'insales_app_core/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'insales_app_core'
  s.version     = InsalesAppCore::VERSION
  s.authors     = ['httplab.ru']
  s.email       = ['dev@httplab.ru']
  s.homepage    = 'http://gitlab.httplab.ru/apps/insales_app_core'
  s.summary     = 'Базовая функциональность проектов для магазина приложений InSales.'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.0.4'
  s.add_dependency 'has_scope'
  s.add_dependency 'insales_api'
  s.add_dependency 'active_link_to'
  s.add_dependency 'slim-rails'
  s.add_dependency 'styx'
  s.add_dependency 'responders'
  s.add_dependency 'unicode'
  s.add_dependency 'nokogiri'
  s.add_dependency 'kaminari'
  s.add_dependency 'colorize'
  s.add_dependency 'bootstrap-sass', '~> 3.1.1'
  s.add_dependency 'bootstrap_form'
end
