# This migration comes from insales_app_core_engine (originally 20140410115219)
class ChangeInsalesIdValueTypeInFieldsValue < ActiveRecord::Migration
  def change
    remove_column :fields_values, :insales_id, :string, null: false
    add_column :fields_values, :insales_id, :integer, null: false
    change_column :fields_values, :value, :text
  end
end
