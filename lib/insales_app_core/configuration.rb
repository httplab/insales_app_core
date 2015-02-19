module InsalesAppCore
  class Configuration
    attr_accessor :insales_api_key,
                  :insales_api_secret,
                  :insales_api_host,
                  :insales_api_autologin_path,
                  :sync_options


    attr_accessor :sync_observers

    def sync_enabled?
      @sync_options && @sync_options.any?{|k,v| v}
    end

    def initialize(&blk)
      blk.call self if block_given?

      setup_insales_api
    end

    def left_menu(&block)
      if block_given?
        @left_menu = InsalesAppCore::AppMenu.new(&block)
      end
      @left_menu
    end

    def right_menu(&block)
      if block_given?
        @right_menu = InsalesAppCore::AppMenu.new(&block)
      end
      @right_menu
    end

    def account_settings(&block)
      if block_given?
        @account_settings = InsalesAppCore::AccountSetting::AccountSettingsCollection.new(&block)
      end
      @account_settings
    end

    def sync_observers_classes
      return [] unless sync_observers.present?
      @sync_observers_classes ||= sync_observers.map { |n| Kernel.const_get(n) }
    end

    private

    def setup_insales_api
      InsalesApi::App.api_key = insales_api_key
      InsalesApi::App.api_secret = insales_api_secret
      InsalesApi::App.api_host = insales_api_host
      InsalesApi::App.api_autologin_path = insales_api_autologin_path
    end
  end
end
