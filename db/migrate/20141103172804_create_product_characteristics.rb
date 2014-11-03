class CreateProductCharacteristics < ActiveRecord::Migration
  def change
    create_table :product_characteristics do |t|
      t.integer :product_id
      t.integer :characteristic_id
      t.integer :account_id

      t.timestamps
    end

    add_index :product_characteristics, [:product_id, :characteristic_id], unique: true, name: 'prod_char_index'
    add_index :product_characteristics, :account_id
  end
end
