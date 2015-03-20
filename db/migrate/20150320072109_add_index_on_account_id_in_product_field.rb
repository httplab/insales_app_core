class AddIndexOnAccountIdInProductField < ActiveRecord::Migration
  def change
    add_index :product_fields, :account_id
  end
end
