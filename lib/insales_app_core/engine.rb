module InsalesAppCore
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework false
    end
  end
end
