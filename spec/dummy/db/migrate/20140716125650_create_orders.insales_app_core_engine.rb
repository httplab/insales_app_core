# This migration comes from insales_app_core_engine (originally 20140408091332)
class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :insales_id, null: false
      t.date :accepted_at
      t.text :comment
      t.text :cookies
      t.string :current_location
      t.date :delivered_at
      t.date :delivery_date
      t.text :delivery_description
      t.integer :delivery_from_hour
      t.integer :delivery_to_hour
      t.decimal :delivery_price
      t.string :delivery_title
      t.integer :insales_delivery_variant_id
      t.string :financial_status
      t.string :fulfillment_status
      t.string :key
      t.decimal :margin
      t.integer :number, null: false
      t.date :paid_at
      t.text :payment_description
      t.integer :insales_payment_gateway_id, null: false
      t.string :payment_title
      t.string :referer
      t.decimal :items_price, null: false
      t.decimal :total_price, null: false
      t.decimal :full_delivery_price, null: false
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
