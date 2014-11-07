class RemoveParentIdFromCollection < ActiveRecord::Migration
  def change
    remove_column :collections, :parent_id, :integer
  end
end
