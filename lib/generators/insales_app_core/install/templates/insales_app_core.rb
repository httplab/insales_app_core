InsalesAppCore.setup do |config|
  # Конфигурация API InSales.
  config.insales_api_key = ENV['INSALES_API_KEY']
  config.insales_api_secret = ENV['INSALES_API_SECRET']
  config.insales_api_host = ENV['INSALES_API_HOST']
  config.insales_api_autologin_path = ENV['INSALES_API_AUTOLOGIN_PATH']
end
