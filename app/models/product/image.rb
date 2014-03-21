class Product::Image < ActiveRecord::Base
  validates :account_id, :product_id, :insales_product_id, :insales_id, :original_url, presence: true
  belongs_to :account
  belongs_to :product

  maps_to_insales
  map_insales_fields product_id: :insales_product_id
end
