class CreateClientGroups < ActiveRecord::Migration
  def change
    create_table :client_groups do |t|
      t.integer :insales_id, null: false
      t.decimal :dicount
      t.boolean :is_default, null: false, default: false
      t.string :title, null: false
      t.text :discount_description
      t.integer :account_id, null: false

      t.timestamps
    end

    add_index :client_groups, :insales_id
    add_index :client_groups, :is_default
  end
end
