class RemoveParentIdFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :parent_id, :integer
  end
end
