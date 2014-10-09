class Variant < ActiveRecord::Base
  validates :account_id, :insales_id, :product_id, :insales_product_id, presence: true
  belongs_to :account
  belongs_to :product
  has_many :order_lines

  maps_to_insales product_id: :insales_product_id
end
