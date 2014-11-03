class Characteristic < ActiveRecord::Base
  validate :account_id, :title, :insales_id, :product_id, :insales_product_id, :property_id,
           :insales_property_id, presence: true
  belongs_to :account
  belongs_to :product
  belongs_to :property
  maps_to_insales product_id: :insales_product_id, property_id: :insales_property_id
end
