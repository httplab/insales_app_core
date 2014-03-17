class AccountsController < ApplicationController
  skip_before_filter :authentication, :configure_api

  def install
    logger.info '[insales_app_core] AccountsController#install'
    logger.info "[insales_app_core] shop: #{params[:shop]}"
    logger.info "[insales_app_core] token: #{params[:token]}"
    logger.info "[insales_app_core] insales_id: #{params[:insales_id]}"

    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])
    insales_id = params[:insales_id]

    Account.create! do |a|
      a.insales_subdomain = shop
      a.insales_password = password
      a.insales_id = insales_id
    end

    render nothing: true, status: :success
  end

  def uninstall
    logger.info '[insales_app_core] AccountsController#uninstall'
    logger.info "[insales_app_core] shop: #{params[:shop]}"
    logger.info "[insales_app_core] token: #{params[:token]}"

    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = params[:token]

    Account.find_by!(insales_subdomain: shop, insales_password: password).destroy!

    render nothing: true, status: :success
  end
end
