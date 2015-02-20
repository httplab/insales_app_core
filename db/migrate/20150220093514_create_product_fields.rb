class CreateProductFields < ActiveRecord::Migration
  def change
    create_table :product_fields do |t|
      t.integer :insales_id, null: false
      t.string :handle
      t.boolean :is_hidden
      t.integer :position
      t.string :title, null: false
      t.string :insales_type
      t.integer :account_id, null: false

      t.timestamps
    end

    add_index :product_fields, :insales_id
  end
end
