class ChangeInsalesIdValueTypeInFieldsValue < ActiveRecord::Migration
  def change
    remove_column :fields_values, :insales_id, :string, null: false
    add_column :fields_values, :insales_id, :integer, null: false
    change_column :fields_values, :value, :text
  end
end
