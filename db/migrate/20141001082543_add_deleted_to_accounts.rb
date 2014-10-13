class AddDeletedToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :deleted, :boolean, default: false
    add_column :accounts, :deleted_at, :datetime
  end
end
