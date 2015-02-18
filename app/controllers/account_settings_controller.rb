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
      if current_account.respond_to?(:settings_changed)
        current_account.settings_changed
      end
    rescue => ex
      flash[:error] = ex.message
    end

    redirect_to root_path
  end
end
