class ProductCharacteristic < ActiveRecord::Base
  validate :insales_product_id, :insales_characteristic_id, :account_id, presence: true
  belongs_to :account
  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id
  belongs_to :characteristic, primary_key: :insales_id, foreign_key: :insales_characteristic_id
end

