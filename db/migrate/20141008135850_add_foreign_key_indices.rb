class AddForeignKeyIndices < ActiveRecord::Migration
  def change
    add_index :orders, :account_id
    add_index :fields, :account_id
    add_index :fields_values, :account_id
    add_index :fields_values, :owner_id
    add_index :fields_values, :field_id

    add_index :order_lines, :account_id
    add_index :order_lines, :order_id
    add_index :order_lines, :product_id
    add_index :order_lines, :variant_id
  end
end
