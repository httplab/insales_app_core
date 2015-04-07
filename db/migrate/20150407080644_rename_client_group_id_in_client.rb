class RenameClientGroupIdInClient < ActiveRecord::Migration
  def change
    rename_column :clients, :client_group_id, :insales_client_group_id
    add_index :clients, :insales_client_group_id
  end
end
