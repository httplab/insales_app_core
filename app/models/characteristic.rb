class Characteristic < ActiveRecord::Base
  validate :account_id, :title, :insales_id, :property_id,
           :insales_property_id, presence: true
  belongs_to :account
  belongs_to :property
  has_many :product_characteristics
  has_many :products, through: :product_characteristics

  maps_to_insales property_id: :insales_property_id
end
