class AddIndicesToCategoryProductImageVariant < ActiveRecord::Migration
  def change
    [:categories, :products, :variants, :images].each do |table|
      add_index table, :account_id
      add_index table, :insales_id
    end

    add_index :categories, :parent_id
    add_index :products, :category_id
    add_index :variants, :product_id
    add_index :images, :product_id
  end
end
