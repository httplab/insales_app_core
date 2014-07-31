class ShippingAddress < ActiveRecord::Base
  belongs_to :account
  belongs_to :order

  maps_to_insales
end
