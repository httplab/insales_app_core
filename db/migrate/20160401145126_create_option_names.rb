class CreateOptionNames < ActiveRecord::Migration
  def change
    create_table :option_names do |t|
      t.integer :insales_id, null: false
      t.references :account, null: false, index: true
      t.integer :position
      t.text :title, null: false

      t.timestamps
    end
    add_index :option_names, :insales_id, unique: true
  end
end
