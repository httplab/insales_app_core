class RenameBalanceReplenishmentsToBalanceChanges < ActiveRecord::Migration
  def change
    rename_table :balance_replenishments, :balance_changes
    add_column :balance_changes, :description, :string
  end
end
