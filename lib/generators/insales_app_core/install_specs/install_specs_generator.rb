require 'colorize'

class InsalesAppCore::InstallSpecsGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../../../spec', __FILE__)

  def install_specs
    directory 'controllers', 'spec/controllers'
    directory 'factories', 'spec/factories'
    directory 'helpers', 'spec/helpers'
    directory 'lib', 'spec/lib'
    directory 'models', 'spec/models'
  end

  def message
    puts "\n>> После установки не забудьте подключить InsalesAppCore::TestHelpers::Controller".green
    puts '>> rails_helper.rb'.green
    puts ">> config.include InsalesAppCore::TestHelpers::Controller, type: :controller\n".green
  end
end
