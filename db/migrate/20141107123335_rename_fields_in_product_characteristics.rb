class RenameFieldsInProductCharacteristics < ActiveRecord::Migration
  def change
    rename_column :product_characteristics, :product_id, :insales_product_id
    rename_column :product_characteristics, :characterisic_id, :insales_characteristic_id
  end
end
