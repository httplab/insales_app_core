class Account < ActiveRecord::Base
  validates :insales_id, :insales_password, :insales_subdomain, presence: true
  validates :insales_id, :insales_subdomain, uniqueness: true

  has_many :categories
  has_many :products
  has_many :variants
  has_many :images
  has_many :orders
  has_many :order_lines
  has_many :fields
  has_many :fields_values
  has_many :settings, class_name: 'AccountSettings', dependent: :destroy

  def self.create_by_insales_request!(params)
    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])
    insales_id = params[:insales_id]

    Account.create! do |a|
      a.insales_subdomain = shop
      a.insales_password = password
      a.insales_id = insales_id
    end
  end

  def self.destroy_by_insales_request!(params)
    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = params[:token]

    Account.find_by!(insales_subdomain: shop, insales_password: password).destroy!
  end

  def create_app
    InsalesApi::App.new(insales_subdomain, insales_password)
  end

  def configure_api
    app = create_app
    app.configure_api
    app
  end

  def get_setting(name)
    InsalesAppCore.config.account_settings.get_value(self, name)
  end

  def set_setting(name, val)
    InsalesAppCore.config.account_settings.set_value(self, name, val)
  end

  [:orders, :products, :clients].each do |ent|
    define_method ("#{ent}_last_sync") do
      (sync_settings || {})[ent.to_s]
    end

    define_method ("#{ent}_last_sync=") do |val|
      z = val.respond_to?(:strftime) ? val.strftime("%Y-%m-%d %H:%M:%S %z") : val
      self.sync_settings = (self.sync_settings || {}).merge({ent.to_s => val})
      val
    end
  end

  def tariff_info
    tariff_conf = Tariffication.config[tariff_id]
    tariff_conf.instance(id) if tariff_conf
  end
end

