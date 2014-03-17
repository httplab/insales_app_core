$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "insales_app_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "insales_app_core"
  s.version     = InsalesAppCore::VERSION
  s.authors     = ["httplab.ru"]
  s.email       = ["dev@httplab.ru"]
  s.homepage    = "http://gitlab.httplab.ru/apps/insales_app_core"
  s.summary     = "Базовая функциональность проектов для магазина приложений InSales."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.4"

  s.add_development_dependency "sqlite3"
end
