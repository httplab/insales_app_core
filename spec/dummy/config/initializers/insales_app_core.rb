InsalesAppCore.setup do |config|
  # Конфигурация API InSales.
  config.insales_api_key = ENV['INSALES_API_KEY']
  config.insales_api_secret = ENV['INSALES_API_SECRET']
  config.insales_api_host = ENV['INSALES_API_HOST']
  config.insales_api_autologin_path = ENV['INSALES_API_AUTOLOGIN_PATH']


  # Левая часть главного меню. Предполагаем, что в левой части основная навигация,
  # пункты ведущие на страницы обспечивающие основную функциональность приложения.
  config.left_menu do |m|
    # Добавить ссылку на "главную" с иконкой-домиком.
    m.add_home

    # Метод add_item принимает три параметра. Первый – название пункта меню, второй – ссылка,
    # последним параметром является блок для конфигурации подменю.
    # Пункт меню, представляющий субменю не должен иметь линка, path вычисляется автоматически
    # исходя из первого элемента подменю.
    # Может быть только один уровень вложенности.

    # m.add_item 'Заказы' do |m|
    #   m.add_item 'CDEK', '/cdek_orders'
    #   m.add_item 'EMS', '/ems_orders'
    #   m.add_item 'Заказы из Insales', '/orders'
    # end
  end

  # Правая часть главного меню. Предполагаем, что в правой части будут различные сервисные
  # ссылки вроде "Помощь", "Настройки".
  config.right_menu do |m|
    m.add_item 'Настройки', '/settings/account/edit'
    # m.add_item 'Помощь', '/help'
  end

  config.account_settings do |as|
    as.setting do |s|
      s.name = :shop_name
      s.title = 'Название магазина'
      s.type = :string
      s.control = :text_field
      s.required = false
    end

    as.setting do |s|
      s.name = :shop_url
      s.title = 'Адрес магазина'
      s.type = :string
      s.control = :text_field
      s.required = false
    end

    as.setting do |s|
      s.name = :always_sync_all
      s.title = 'Всегда синхронизировать всё'
      s.type = :boolean
      s.control = :checkbox
      s.required = true
      s.default_value true
    end
  end
end
