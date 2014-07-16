# This migration comes from insales_app_core_engine (originally 20140505085633)
class AddShopNameShopUrlToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :shop_name, :string
    add_column :account_settings, :shop_url, :string
  end
end
