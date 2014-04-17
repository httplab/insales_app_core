class AddAccountIdToAccountSettings < ActiveRecord::Migration
  def change
    change_table :account_settings do |t|
      t.references :account, index: true
      t.string :from_address
    end
  end
end
