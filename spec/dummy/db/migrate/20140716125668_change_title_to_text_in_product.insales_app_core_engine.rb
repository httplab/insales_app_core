# This migration comes from insales_app_core_engine (originally 20140702081844)
class ChangeTitleToTextInProduct < ActiveRecord::Migration
  def up
    change_column :products, :title, :text
  end

  def down
    change_column :products, :title, :string
  end
end
