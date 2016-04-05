class CreateOptionValues < ActiveRecord::Migration
  def change
    create_table :option_values do |t|
      t.integer :insales_id, null: false
      t.references :account, null: false, index: true
      t.references :option_name, null: false, index: true
      t.integer :position
      t.text :title, null: false

      t.timestamps
    end
    add_index :option_values, :insales_id, unique: true
  end
end
