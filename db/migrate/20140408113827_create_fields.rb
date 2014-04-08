class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
        t.integer :insales_id, null: false
        t.boolean :active, null: false
        t.integer :destiny, null: false
        t.boolean :for_buyer, null: false
        t.boolean :obligatory, null: false
        t.string :office_title, null: false
        t.integer :position, null: false
        t.boolean :show_in_checkout, null: false
        t.boolean :show_in_result, null: false
        t.string :system_name
        t.string :title
        t.string :example
        t.integer :account_id, null: false
        t.timestamps
    end
  end
end
