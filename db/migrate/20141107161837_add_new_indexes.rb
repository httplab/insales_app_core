class AddNewIndexes < ActiveRecord::Migration
  def change
    add_index :collections, :account_id
    add_index :collections, :insales_parent_id

    add_index :images, :insales_product_id

    add_index :order_lines, :insales_product_id

    add_index :variants, :insales_product_id
  end
end
