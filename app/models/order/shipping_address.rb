class Order
  class ShippingAddress < ActiveRecord::Base
    self.table_name = 'shipping_addresses'

    belongs_to :account
    belongs_to :order, primary_key: :insales_id, foreign_key: :insales_order_id

    maps_to_insales
  end
end
