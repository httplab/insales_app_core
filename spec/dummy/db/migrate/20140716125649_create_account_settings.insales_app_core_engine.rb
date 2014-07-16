# This migration comes from insales_app_core_engine (originally 20140401130311)
class CreateAccountSettings < ActiveRecord::Migration
  def change
    create_table :account_settings do |t|
      t.string :admin_email

      t.timestamps
    end
  end
end
