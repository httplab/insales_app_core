class RemoveOrderIdFromOrderLine < ActiveRecord::Migration
  def change
    remove_column :order_lines, :order_id, :integer
  end
end
