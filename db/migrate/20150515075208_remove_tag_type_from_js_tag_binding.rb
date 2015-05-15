class RemoveTagTypeFromJsTagBinding < ActiveRecord::Migration
  def change
    remove_column :js_tag_bindings, :tag_type, :integer
  end
end
