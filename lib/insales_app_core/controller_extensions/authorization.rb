module InsalesAppCore
  module ControllerExtensions
    module Authorization
      extend ActiveSupport::Concern

      included do
        before_action :store_after_sign_in_location, :authenticate, :configure_api
        prepend_before_action :authenticate, :configure_api

        helper_method :current_account, :current_insales_app, :logged_in?
      end

      def authenticate
        logout if enter_from_different_shop?

        # Если приложение Insales висит в API и авторизовано, просто ищем нужный акконут.
        if current_insales_app && current_insales_app.authorized?
          return if self.current_account = Account.where(deleted: false).find_by_insales_subdomain(current_insales_app.shop)
        end

        # В противном случае предполагаем, что нужная информация есть в params
        # и пробуем авторизовать клиента.
        if authorize_by_params!
          redirect_to current_insales_app.authorization_url
        else
          # Делаем редирект на страницу логина в том случае, если текущая страница не статическая.
          # TODO: как-то конфигурировать страницы, которые можно показывать на без аутентификации.
          if controller_name != 'pages'
            redirect_to new_session_path
          end
        end
      end

      def store_after_sign_in_location
        unless logged_in?
          session[:after_sign_in_location] = request.fullpath
        end
      end

      def configure_api
        current_insales_app.configure_api if current_insales_app
      end

      def logout
        reset_session
      end

      def authorize_by_params!
        self.current_account = if params[:insales_id]
          Account.where(deleted: false).find_by_insales_id(params[:insales_id])
        else
          shop_wo_http = (params[:shop] || "")[/[\w\d-]+\.myinsales.ru/]
          Account.where(deleted: false).find_by_insales_subdomain(InsalesApi::App.prepare_shop(shop_wo_http))
        end

        return nil unless @current_account
        self.current_insales_app = current_account.create_app
      end

      def enter_from_different_shop?
        return false unless params[:shop]

        params_shop = InsalesApi::App.prepare_shop(params[:shop])
        current_insales_app && params_shop != current_insales_app.shop
      end

      def logged_in?
        current_insales_app.present? && current_insales_app.authorized? && current_account.present?
      end

      def current_account
        @current_account
      end

      def current_account=(acc)
        @current_account = acc
      end

      def current_insales_app
        session[:current_insales_app]
      end

      def current_insales_app=(app)
        session[:current_insales_app] = app
      end

      def clear_after_sign_in_location
        session[:after_sign_in_location] = nil
      end

      def after_sign_in_location
        session[:after_sign_in_location]
      end
    end
  end
end
