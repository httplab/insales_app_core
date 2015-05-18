class AddTestModeToJsTagBinding < ActiveRecord::Migration
  def change
    add_column :js_tag_bindings, :test_mode, :boolean, null: false, default: false
  end
end
