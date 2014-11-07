class RemoveProductIdFromImage < ActiveRecord::Migration
  def change
    remove_column :images, :product_id, :integer
  end
end
