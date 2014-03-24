class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.string :title
      t.string :sku, null: false
      t.integer :insales_id, null: false
      t.integer :product_id, null: false
      t.integer :insales_product_id, null: false
      t.decimal :cost_price
      t.decimal :old_price
      t.decimal :price
      t.integer :quantity
      t.decimal :weight
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
