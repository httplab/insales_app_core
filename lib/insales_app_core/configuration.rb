module InsalesAppCore
  class Configuration
    attr_accessor :insales_api_key,
                  :insales_api_secret,
                  :insales_api_host,
                  :insales_api_autologin_path


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

    private

    def setup_insales_api
      InsalesApi::App.api_key = insales_api_key
      InsalesApi::App.api_secret = insales_api_secret
      InsalesApi::App.api_host = insales_api_host
      InsalesApi::App.api_autologin_path = insales_api_autologin_path
    end
  end
end
