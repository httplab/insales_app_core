class AllowEmptySku < ActiveRecord::Migration
  def change
    change_column :variants, :sku, :string, null: true
  end
end
