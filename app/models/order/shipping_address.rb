class Order
  class ShippingAddress < ActiveRecord::Base
    self.table_name = 'shipping_addresses'

    belongs_to :account
    belongs_to :order

    maps_to_insales
  end
end
