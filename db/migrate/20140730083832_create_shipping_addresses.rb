class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.references :account, null: false, index: true
      t.references :order, null: false, index: true
      t.integer :insales_id
      t.text :name
      t.text :surname
      t.text :middlename
      t.text :phone
      t.text :address
      t.text :city
      t.text :state
      t.text :country
      t.text :zip
      t.timestamps
    end
  end
end
