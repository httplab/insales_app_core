class AccountSettings < ActiveRecord::Base
  belongs_to :account

  after_create :populate_defaults!

  def populate_defaults!
    self.shop_name = fetch_current_title
    self.shop_url = 'http://' + fetch_current_subdomain + '.myinsales.ru'
    save!
  end

  def fetch_current_title
    InsalesApi::Account.current.title
  end

  def fetch_current_subdomain
    InsalesApi::Account.current.subdomain
  end
end
