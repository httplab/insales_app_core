class CreateCollects < ActiveRecord::Migration
  def change
    create_table :collects do |t|
      t.integer :product_id, null: false
      t.integer :collection_id, null: false
      t.integer :account_id, null: false
      t.timestamps
    end

    add_index :collects, [:product_id, :collection_id], unique: true
    add_index :collects, :account_id
  end
end
