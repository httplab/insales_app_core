class ChangeDeliveryTitleInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :delivery_title, :text
  end
end
