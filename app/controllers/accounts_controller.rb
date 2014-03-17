class AccountsController < ApplicationController
  skip_before_filter :authentication, :configure_api

  def install
    logger.info '--- AccountsController#install'
    logger.info "shop: #{params[:shop]}"
    logger.info "token: #{params[:token]}"
    logger.info "insales_id: #{params[:insales_id]}"

    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])
    insales_id = params[:insales_id]

    Account.create! do |a|
      a.insales_subdomain = shop
      a.insales_password = password
      a.insales_id = insales_id
    end

    render nothing: true, status: :created
  end

  def uninstall
    logger.info '--- AccountsController#uninstall'
    logger.info "shop: #{params[:shop]}"
    logger.info "token: #{params[:token]}"

    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])

    Account.find_by!(insales_subdomain: shop, insales_password: password).destroy!

    render nothing: true, status: :success
  end
end
