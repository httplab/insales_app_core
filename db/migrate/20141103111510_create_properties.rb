class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.integer :insales_id, null: false
      t.integer :account_id, null: false
      t.integer :position
      t.text :title, null: false
      t.text :permalink

      t.timestamps
    end
    add_index :properties, :insales_id, unique: true
    add_index :properties, :account_id
  end
end
