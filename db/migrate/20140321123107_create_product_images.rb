class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :insales_id, null: false
      t.integer :product_id, null: false
      t.integer :insales_product_id, null: false
      t.string :title
      t.integer :position
      t.string :original_url, null: false
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
