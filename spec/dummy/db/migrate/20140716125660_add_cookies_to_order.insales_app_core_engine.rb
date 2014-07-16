# This migration comes from insales_app_core_engine (originally 20140411090605)
class AddCookiesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :cookies, :hstore
  end
end
