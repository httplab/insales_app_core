# This migration comes from insales_app_core_engine (originally 20140414054437)
class ChangeDeliveryTitleInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :delivery_title, :text
  end
end
