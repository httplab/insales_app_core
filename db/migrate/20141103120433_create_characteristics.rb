class CreateCharacteristics < ActiveRecord::Migration
  def change
    create_table :characteristics do |t|
      t.integer :insales_id, null: false
      t.integer :account_id, null: false
      t.integer :insales_property_id, null: false
      t.integer :property_id, null: false
      t.text :title, null: false
      t.text :permalink

      t.timestamps
    end

    add_index :characteristics, :insales_id, unique: true
    add_index :characteristics, :account_id
    add_index :characteristics, :property_id
    add_index :characteristics, :insales_property_id
  end
end
