class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :insales_id, null: false
      t.integer :parent_id
      t.integer :insales_parent_id
      t.integer :position
      t.string :title
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end