class AccountSettingsController < ApplicationController
  include AccountSettingsControllerBase

  respond_to :html
  responders :flash
  before_filter :fetch_account_settings
end
