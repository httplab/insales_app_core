class Order < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_delivery_variant_id,
   :number, :insales_payment_gateway_id, :items_price, :total_price, :full_delivery_price,
    presence: true

  belongs_to :account
  belongs_to :client
  has_many :fields_values ,-> {joins(:field).where('fields.destiny = 3') }, class_name: FieldsValue, foreign_key: :owner_id, dependent: :destroy
  has_many :order_lines, dependent: :destroy
  has_one :shipping_address, class_name: 'Order::ShippingAddress', dependent: :destroy

  maps_to_insales :delivery_variant_id => :insales_delivery_variant_id,
                  :payment_gateway_id => :insales_payment_gateway_id,
                  :cookies => nil

  def client_name
    client.try(:full_name)
  end
end
