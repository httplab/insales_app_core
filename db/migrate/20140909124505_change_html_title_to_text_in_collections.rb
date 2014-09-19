class ChangeHtmlTitleToTextInCollections < ActiveRecord::Migration
  def up
    change_column :collections, :html_title, :text
  end

  def down
    change_column :collections, :html_title, :string
  end
end
