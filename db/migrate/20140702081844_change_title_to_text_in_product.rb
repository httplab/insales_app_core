class ChangeTitleToTextInProduct < ActiveRecord::Migration
  def up
    change_column :products, :title, :text
  end

  def down
    change_column :products, :title, :string
  end
end
