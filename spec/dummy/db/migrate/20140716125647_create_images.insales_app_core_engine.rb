# This migration comes from insales_app_core_engine (originally 20140321123107)
class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
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
