class RemoveFieldIdFromFieldsValue < ActiveRecord::Migration
  def change
    remove_column :fields_values, :field_id, :integer
  end
end
