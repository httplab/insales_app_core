class Account < ActiveRecord::Base
  validates :insales_id, :insales_password, :insales_subdomain, presence: true
  validates :insales_id, :insales_subdomain, uniqueness: true

  has_many :categories
  has_many :products
  has_many :variants
  has_many :product_images

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
  end
end

