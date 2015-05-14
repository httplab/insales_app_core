class CreateJsTagBindings < ActiveRecord::Migration
  def change
    create_table :js_tag_bindings do |t|
      t.string :label, null: false
      t.string :checksum
      t.integer :account_id, null: false
      t.integer :insales_js_tag_id
      t.integer :tag_type, null: false, default: 0

      t.timestamps
    end

    add_index :js_tag_bindings, :account_id
    add_index :js_tag_bindings, :label
    add_index :js_tag_bindings, [:account_id, :label], unique: true
  end
end
