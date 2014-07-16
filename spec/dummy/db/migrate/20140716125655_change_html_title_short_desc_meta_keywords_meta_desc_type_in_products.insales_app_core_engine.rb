# This migration comes from insales_app_core_engine (originally 20140410110606)
class ChangeHtmlTitleShortDescMetaKeywordsMetaDescTypeInProducts < ActiveRecord::Migration
  def change
    change_column :products, :html_title, :text
    change_column :products, :short_description, :text
    change_column :products, :meta_keywords, :text
    change_column :products, :meta_description, :text
  end
end

