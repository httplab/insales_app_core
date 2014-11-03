class ProductCharacteristic < ActiveRecord::Base
  validate :product_id, :characteristic_id, :account_id, presence: true
  belongs_to :account
  belongs_to :product
  belongs_to :characteristic
end

