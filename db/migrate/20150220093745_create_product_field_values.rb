class CreateProductFieldValues < ActiveRecord::Migration
  def change
    create_table :product_field_values do |t|
      t.integer :insales_id, null: false
      t.integer :insales_product_field_id, null: false
      t.integer :insales_product_id, null: false
      t.string :value

      t.timestamps
    end

    add_index :product_field_values, :insales_id
    add_index :product_field_values, :insales_product_id
    add_index :product_field_values, :insales_product_field_id
    add_index :product_field_values, [:insales_product_field_id, :insales_product_id], unique: true, name: :pfv_unq_idx
  end
end
