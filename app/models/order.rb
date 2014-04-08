class Order < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_delivery_variant_id,
   :number, :insales_payment_gateway_id, :items_price, :total_price, :full_delivery_price,
    presence: true

  belongs_to :account

  maps_to_insales :delivery_variant_id => :insales_delivery_variant_id,
                  :payment_gateway_id => :insales_payment_gateway_id
end
