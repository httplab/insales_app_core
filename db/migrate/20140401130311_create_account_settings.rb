class CreateAccountSettings < ActiveRecord::Migration
  def change
    create_table :account_settings do |t|
      t.string :admin_email

      t.timestamps
    end
  end
end
