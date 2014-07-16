# This migration comes from insales_app_core_engine (originally 20140410114324)
class ChangeRefererCurrentLocationTypeOfOrder < ActiveRecord::Migration
  def change
    change_column :orders, :referer, :text
    change_column :orders, :current_location, :text
  end
end
