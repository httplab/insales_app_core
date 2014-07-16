# This migration comes from insales_app_core_engine (originally 20140410113714)
class RemoveCookiesFromOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :cookies
  end

  def down
    add_column :orders, :cookies, :string
  end
end
