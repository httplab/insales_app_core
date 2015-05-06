class SessionsController < ApplicationController
  skip_before_filter :authenticate, :configure_api, :store_after_sign_in_location

  def new
    # TODO: Заменить более вменяемым исключением.
    raise 'already logged' if logged_in?

    if params[:shop] && params[:insales_id]
      create
      return
    end
  end

  def create
    if authorize_by_params!
      redirect_to current_insales_app.authorization_url
    else
      flash.now[:error] = "Не удалось выполнить вход. Убедитесь, что адрес магазина указан правильно."
      render action: :new
    end
  end

  def autologin
    unless current_insales_app
      flash[:error] = "Не удалось выполнить вход. Убедитесь, что адрес магазина указан правильно."
      redirect_to new_session_path
      return
    end

    if current_insales_app.authorize(params[:token])
      redirect_to root_path
    else
      flash[:error] = "Не удалось выполнить вход. Неверный токен авторизации."
      redirect_to new_session_path
    end
  end

  def destroy
    logout
    redirect_to new_session_path
  end
end
