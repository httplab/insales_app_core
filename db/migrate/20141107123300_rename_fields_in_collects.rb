class RenameFieldsInCollects < ActiveRecord::Migration
  def change
    rename_column :collects, :product_id, :insales_product_id
    rename_column :collects, :collection_id, :insales_collection_id
  end
end
