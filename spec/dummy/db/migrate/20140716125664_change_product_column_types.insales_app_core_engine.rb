# This migration comes from insales_app_core_engine (originally 20140521144906)
class ChangeProductColumnTypes < ActiveRecord::Migration
  def up
    change_column :products, :meta_description, :text
    change_column :products, :short_description, :text
  end

  def down
    change_column :products, :meta_description, :string
    change_column :products, :short_description, :string
  end
end
