class Account < ActiveRecord::Base
  validates :insales_id, :insales_password, :insales_subdomain, presence: true

  has_many :categories
  has_many :collections
  has_many :products
  has_many :variants
  has_many :images
  has_many :orders
  has_many :order_lines
  has_many :fields
  has_many :fields_values
  has_many :settings, class_name: 'AccountSettings'
  has_many :clients
  has_many :properties
  has_many :characteristics

  before_update :set_deleted_at, if: 'deleted_changed?'

  # TODO: Более оптимально вычислять был ли засинкан аккаунт
  def self.for_sync
    where(deleted: false).to_ary.select { |a| a.initial_sync_completed? }
  end

  def self.installed?(params)
    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])

    Account.exists?(insales_subdomain: shop, insales_password: password, deleted: false)
  end


  def self.create_by_insales_request!(params)
    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = InsalesApi::App.password_by_token(params[:token])
    insales_id = params[:insales_id]

    acc = Account.where(insales_id: insales_id, insales_subdomain: shop, deleted: true).first

    if acc.present?
      acc.update_attributes(insales_password: password, deleted: false, last_install_date: DateTime.current)
      acc
    else
      Account.create! do |a|
        a.insales_subdomain = shop
        a.insales_password = password
        a.insales_id = insales_id
        a.last_install_date = DateTime.current
      end
    end
  end

  def self.set_deleted_by_insales_request!(params)
    shop = InsalesApi::App.prepare_shop(params[:shop])
    password = params[:token]

    a = Account.find_by!(insales_subdomain: shop, insales_password: password, deleted: false)
    a.deleted = true
    a.save!
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

  # Была ли выполнена первоначальная синхронизация
  def initial_sync_completed?
    !!last_sync_date
  end

  # Время последней синхронизации
  def last_sync_date
    arr = [:orders, :products, :clients].map { |m| send("#{m}_last_sync") }
    # Если по какому-то из ентити синхронизации не было, считаем, что ее не было вообще.
    return nil if arr.index(nil)
    arr.map { |m| DateTime.parse(m) }.max
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

  def set_deleted_at
    if deleted?
      self.deleted_at = DateTime.now
    else
      self.deleted_at = nil
    end
  end
end

