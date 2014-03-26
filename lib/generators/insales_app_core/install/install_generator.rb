class InsalesAppCore::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def migrations
    rake 'insales_app_core_engine:install:migrations'
  end

  def configuration
    copy_file 'insales_app_core.rb', 'config/initializers/insales_app_core.rb'
  end

  def add_assets
    inject_into_file "app/assets/javascripts/application.js", after: "//= require jquery_ujs\n" do
      <<-EOF.strip_heredoc
        //= require insales_app_core
      EOF
    end

    inject_into_file "app/assets/stylesheets/application.css.scss",
                     after: " */\n" do
      <<-EOF.strip_heredoc
        @import "insales_app_core";
      EOF
    end
  end

  def add_application_yml_keys
    app_name = Rails.application.class.parent_name.underscore
    append_file 'config/application.yml' do
      "\nINSALES_API_KEY: '#{app_name}'\n" +
      "INSALES_API_SECRET: 'xa0242zz4e477f4e2f36016e72f0990a'\n" +
      "INSALES_API_HOST: 'localhost:3000'\n" +
      "INSALES_API_AUTOLOGIN_PATH: 'session/autologin'"
    end
  end
end
