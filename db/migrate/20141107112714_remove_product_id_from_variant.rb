class RemoveProductIdFromVariant < ActiveRecord::Migration
  def change
    remove_column :variants, :product_id, :integer
  end
end
