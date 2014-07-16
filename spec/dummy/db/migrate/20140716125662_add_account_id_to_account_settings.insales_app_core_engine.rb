# This migration comes from insales_app_core_engine (originally 20140417075406)
class AddAccountIdToAccountSettings < ActiveRecord::Migration
  def change
    change_table :account_settings do |t|
      t.references :account, index: true
      t.string :from_address
    end
  end
end
