class Variant < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_product_id, presence: true
  belongs_to :account
  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :order_lines

  maps_to_insales product_id: :insales_product_id
end
