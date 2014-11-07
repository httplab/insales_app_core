class RenameOrderIdInShippingAddress < ActiveRecord::Migration
  def change
    rename_column :shipping_addresses, :order_id, :insales_order_id
  end
end
