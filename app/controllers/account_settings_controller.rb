class AccountSettingsController < ApplicationController
  respond_to :html
  responders :flash

  def edit
    @settings = InsalesAppCore.config.account_settings
  end

  def update
    begin
      InsalesAppCore.config.account_settings.each do |s|
        val = params[s.name]
        current_account.set_setting(s.name, val)
      end
    rescue => ex
      flash[:error] = ex.message
    end

    redirect_to edit_account_settings_path
  end

end
