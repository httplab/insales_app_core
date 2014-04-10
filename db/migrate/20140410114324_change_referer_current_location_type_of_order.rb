class ChangeRefererCurrentLocationTypeOfOrder < ActiveRecord::Migration
  def change
    change_column :orders, :referer, :text
    change_column :orders, :current_location, :text
  end
end
