# This migration comes from insales_app_core_engine (originally 20140711093429)
class AlterAccountSettings < ActiveRecord::Migration
  def up
    drop_table :account_settings
    create_table :account_settings do |t|
      t.references :account, index: true
      t.string :name
      t.text :value
      t.timestamps
    end
  end

  def down
    drop_table :account_settings

    create_table :account_settings do |t|
      t.string :admin_email
      t.references :account, index: true
      t.string :from_address
      t.string :shop_name
      t.string :shop_url
      t.timestamps
    end
  end
end
