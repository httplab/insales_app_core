# This migration comes from insales_app_core_engine (originally 20140410113726)
class AllowEmptySku < ActiveRecord::Migration
  def change
    change_column :variants, :sku, :string, null: true
  end
end
