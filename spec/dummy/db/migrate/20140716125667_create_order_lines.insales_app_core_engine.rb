# This migration comes from insales_app_core_engine (originally 20140605090138)
class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.integer :insales_id, null: false
      t.integer :order_id, null: false
      t.integer :insales_order_id, null: false
      t.integer :product_id, null: false
      t.integer :insales_product_id, null: false
      t.integer :variant_id, null: false
      t.integer :insales_variant_id, null: false
      t.integer :quantity, null: false
      t.integer :reserved_quantity
      t.decimal :sale_price
      t.string :sku
      t.text :title
      t.decimal :weight
      t.decimal :full_sale_price
      t.decimal :total_price
      t.decimal :full_total_price
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
