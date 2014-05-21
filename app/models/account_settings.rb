class AccountSettings < ActiveRecord::Base
  belongs_to :account

  after_create :populate_defaults!

  def populate_defaults!
    self.shop_name = fetch_current_title
    self.shop_url = 'http://' + fetch_current_subdomain + '.myinsales.ru'
    save!
  end

  # Т.к. вызовы осуществляются в коллбэках, а API инсейлс не сконфигурировано
  # сразу после создания аккаунта, конфигурируем по-месту.
  def fetch_current_title
    account.configure_api
    InsalesApi::Account.current.title
  end

  def fetch_current_subdomain
    account.configure_api
    InsalesApi::Account.current.subdomain
  end
end
