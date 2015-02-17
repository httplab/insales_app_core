class AddLastInstallDateToAccount < ActiveRecord::Migration
  def up
    add_column :accounts, :last_install_date, :datetime
    sql = 'UPDATE accounts SET last_install_date = created_at'
    execute(sql)
    change_column :accounts, :last_install_date, :datetime, null: false
  end

  def down
    remove_column :accounts, :last_install_date
  end
end
