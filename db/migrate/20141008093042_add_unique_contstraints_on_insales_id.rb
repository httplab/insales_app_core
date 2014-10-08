class AddUniqueContstraintsOnInsalesId < ActiveRecord::Migration
  def change
    remove_index :products, column: :insales_id
    add_index :products, :insales_id, unique: true

    remove_index :categories, column: :insales_id
    add_index :categories, :insales_id, unique: true

    remove_index :variants, column: :insales_id
    add_index :variants, :insales_id, unique: true

    remove_index :images, column: :insales_id
    add_index :images, :insales_id, unique: true
    add_index :orders, :insales_id, unique: true
    add_index :fields, :insales_id, unique: true
    add_index :fields_values, :insales_id, unique: true
    add_index :order_lines, :insales_id, unique: true
    add_index :clients, :insales_id, unique: true
    add_index :collections, :insales_id, unique: true
    add_index :shipping_addresses, :insales_id, unique: true

  end
end
