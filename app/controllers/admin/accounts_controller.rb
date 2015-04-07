class Admin::AccountsController < Admin::ApplicationController
  respond_to :html

  def index
    @accounts = Account.all
  end

  def sign_in
    @account = Account.find(params[:id])
    current_insales_app = @account.create_app
    current_insales_app.configure_api
    current_insales_app.instance_variable_set(:@authorized, true)
    session[:current_insales_app] = current_insales_app
    respond_with @account, location: root_path
  end
end
