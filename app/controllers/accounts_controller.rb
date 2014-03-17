class AccountsController < ApplicationController
  skip_before_filter :authentication, :configure_api

  def install
    Account.create_by_insales_request! params
    render nothing: true, status: 200
  end

  def uninstall
    Account.destroy_by_insales_request! params
    render nothing: true, status: 200
  end
end
