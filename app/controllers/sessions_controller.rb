class SessionsController < ApplicationController
  # skip_before_filter :authentication, :configure_api, :except => [:destroy]
  # layout 'login'

  # def new
  #   puts __method__.inspect
  #   if params.has_key?('shop') and params.has_key?('insales_id')
  #     create
  #     return
  #   end
  # end

  # def show
  #   puts __method__.inspect
  #   render :action => :new
  # end

  # def create
  #   puts __method__.inspect
  #   @shop = params[:shop]

  #   if account_by_params
  #     init_authorization account_by_params
  #   else
  #     flash.now[:error] = "Убедитесь, что адрес магазина указан правильно."
  #     render :action => :new
  #   end
  # end

  # def autologin
  #   puts __method__.inspect
  #   if current_app and current_app.authorize params[:token]
  #     if location.present? #&& location.scan('orders/post').any?
  #       redirect_to location
  #       session[:return_to] = nil
  #     else
  #       redirect_to root_path
  #     end
  #   else
  #     redirect_to login_path
  #   end
  # end

  # def destroy
  #   puts __method__.inspect
  #   logout
  #   redirect_to login_path
  # end
end
