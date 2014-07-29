class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.references :account, index: true, null: false
      t.integer :insales_id, null: false
      t.text :name, null: false
      t.text :surname
      t.text :middlename
      t.string :email
      t.string :phone
      t.boolean :registered, default: false
      t.boolean :subscribe, default: false
      t.integer :bonus_points, default: 0
      t.integer :client_group_id
      t.timestamps
    end
  end
end
