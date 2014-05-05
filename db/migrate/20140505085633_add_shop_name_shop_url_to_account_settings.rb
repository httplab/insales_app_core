class AddShopNameShopUrlToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :shop_name, :string
    add_column :account_settings, :shop_url, :string
  end
end
