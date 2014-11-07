class Characteristic < ActiveRecord::Base
  validate :account_id, :title, :insales_id,
           :insales_property_id, presence: true
  belongs_to :account
  belongs_to :property, foreign_key: :insales_property_id, primary_key: :insales_id
  has_many :product_characteristics, foreign_key: :insales_characteristic_id, primary_key: :insales_id
  has_many :products, through: :product_characteristics

  maps_to_insales property_id: :insales_property_id
end
