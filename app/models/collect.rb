class Collect < ActiveRecord::Base
  belongs_to :collection, foreign_key: :insales_collection_id, primary_key: :insales_id
  belongs_to :product, foreign_key: :insales_product_id, primary_key: :insales_id
end
