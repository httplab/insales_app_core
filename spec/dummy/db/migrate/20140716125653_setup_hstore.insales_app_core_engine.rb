# This migration comes from insales_app_core_engine (originally 20140409131557)
class SetupHstore < ActiveRecord::Migration
  def self.up
    enable_extension "hstore"
  end

  def self.down
    disable_extension "hstore"
  end
end
