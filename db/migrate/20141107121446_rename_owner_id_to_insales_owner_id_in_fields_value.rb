class RenameOwnerIdToInsalesOwnerIdInFieldsValue < ActiveRecord::Migration
  def change
    rename_column :fields_values, :owner_id, :insales_owner_id
  end
end
