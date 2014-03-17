class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :insales_id, null: false
      t.string :insales_password, null: false
      t.string :insales_subdomain, null: false

      t.timestamps
    end

    add_index :accounts, :insales_id, unique: true
    add_index :accounts, :insales_subdomain, unique: true
  end
end

