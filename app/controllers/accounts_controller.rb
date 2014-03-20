class AccountsController < ApplicationController
  skip_before_filter :authenticate, :configure_api, :store_after_sign_in_location

  def install
    Account.create_by_insales_request! params
    render nothing: true, status: 200
  end

  def uninstall
    Account.destroy_by_insales_request! params
    render nothing: true, status: 200
  end
end
