# This migration comes from insales_app_core_engine (originally 20140408124005)
class CreateFieldsValues < ActiveRecord::Migration
  def change
    create_table :fields_values do |t|
      t.string :insales_id, null: false
      t.integer :field_id, null: false
      t.integer :owner_id, null: false
      t.integer :insales_field_id, null: false
      t.string :name, null: false
      t.string :value
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
