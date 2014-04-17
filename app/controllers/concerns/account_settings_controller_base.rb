module AccountSettingsControllerBase
  def edit
    respond_with @account_settings
  end

  def update
    @account_settings.update_attributes(fetch_params)
    respond_with @account_settings, location: edit_account_settings_path
  end

  def fetch_account_settings
    @account_settings = current_account.settings
  end

  def fetch_params
    params.require(:account_settings).permit(*permitted_params)
  end

  def permitted_params
    [:admin_email,
     :from_address]
  end
end
