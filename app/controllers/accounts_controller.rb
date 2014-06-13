class AccountsController < ApplicationController
  skip_before_filter :authenticate, :configure_api, :store_after_sign_in_location

  def install
    @new_account = Account.create_by_insales_request! params
    render nothing: true, status: 200
  end

  def uninstall
    @deleted_accout = Account.destroy_by_insales_request! params
    render nothing: true, status: 200
  end
end
