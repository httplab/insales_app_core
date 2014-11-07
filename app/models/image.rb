class Image < ActiveRecord::Base
  validates :account_id, :insales_product_id, :insales_id, :original_url, presence: true
  belongs_to :account
  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id

  maps_to_insales product_id: :insales_product_id
end
