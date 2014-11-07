class RemoveVariantIdFromOrderLines < ActiveRecord::Migration
  def change
    remove_column :order_lines, :variant_id, :integer
  end
end
