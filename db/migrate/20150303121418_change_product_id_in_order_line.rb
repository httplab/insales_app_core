class ChangeProductIdInOrderLine < ActiveRecord::Migration
  def change
    change_column :order_lines, :insales_product_id, :integer, null: true
  end
end
