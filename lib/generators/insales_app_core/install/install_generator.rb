class InsalesAppCore::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def migrations
    rake 'insales_app_core_engine:install:migrations'
  end

  def configuration
    copy_file 'insales_app_core.rb', 'config/initializers/insales_app_core.rb'
  end
end
