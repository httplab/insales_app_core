class AddSyncSettingsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :sync_settings, :hstore
  end
end
