class Variant < ActiveRecord::Base
  validates :account_id, :insales_id, :product_id, :insales_product_id, :sku, presence: true
  belongs_to :account
  belongs_to :product

  maps_to_insales
  map_insales_fields product_id: :insales_product_id
end
