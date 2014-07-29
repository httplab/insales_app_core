class AddClientFieldsToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :client, index: true
    add_column :orders, :insales_client_id, :integer
  end
end
