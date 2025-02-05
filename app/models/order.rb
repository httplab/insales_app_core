class Order < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_delivery_variant_id,
   :number, :insales_payment_gateway_id, :items_price, :total_price, :full_delivery_price,
   :insales_client_id,
    presence: true

  belongs_to :account
  belongs_to :client, foreign_key: :insales_client_id, primary_key: :insales_id
  has_many :fields_values ,-> {joins(:field).where('fields.destiny = ?', Field::DESTINY_ORDER) }, class_name: FieldsValue, foreign_key: :insales_owner_id, dependent: :destroy, primary_key: :insales_id
  has_many :order_lines, dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_order_id
  has_one :shipping_address, class_name: 'Order::ShippingAddress', dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_order_id

  maps_to_insales :delivery_variant_id => :insales_delivery_variant_id,
                  :payment_gateway_id => :insales_payment_gateway_id,
                  :cookies => nil

  def client_name
    client.try(:full_name)
  end
end
