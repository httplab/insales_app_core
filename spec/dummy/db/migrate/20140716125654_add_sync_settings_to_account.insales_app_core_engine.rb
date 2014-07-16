# This migration comes from insales_app_core_engine (originally 20140409131721)
class AddSyncSettingsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :sync_settings, :hstore
  end
end
