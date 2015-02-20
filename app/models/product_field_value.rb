class ProductFieldValue < ActiveRecord::Base
  validates :insales_id, :insales_product_id, :insales_product_field_id, presence: true

  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id
  belongs_to :product_field, primary_key: :insales_id, foreign_key: :insales_product_field_id

  maps_to_insales product_id: :insales_product_id, product_field_id: :insales_product_field_id
end
