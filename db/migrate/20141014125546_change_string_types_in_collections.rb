class ChangeStringTypesInCollections < ActiveRecord::Migration
  def change
    change_column :collections, :title, :text, null: false
    change_column :collections, :html_title, :text
    change_column :collections, :meta_keywords, :text
    change_column :collections, :url, :text
    change_column :collections, :url, :text
  end
end
