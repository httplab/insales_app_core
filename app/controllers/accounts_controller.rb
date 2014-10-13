class AccountsController < ApplicationController
  skip_before_filter :authenticate, :configure_api, :store_after_sign_in_location

  def install
    if Account.installed? params
      render nothing: true, status: 422
    else
      @new_account = Account.create_by_insales_request! params
      render nothing: true, status: 200
    end
  end

  def uninstall
    @deleted_accout = Account.set_deleted_by_insales_request! params
    render nothing: true, status: 200
  end
end
