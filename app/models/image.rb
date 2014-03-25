class Image < ActiveRecord::Base
  validates :account_id, :product_id, :insales_product_id, :insales_id, :original_url, presence: true
  belongs_to :account
  belongs_to :product

  maps_to_insales product_id: :insales_product_id
end