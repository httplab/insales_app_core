class ProductField < ActiveRecord::Base
  validates :insales_id, presence: true

  belongs_to :account

  has_many :product_field_values, primary_key: :insales_id, foreign_key: :insales_product_field_id,
           dependent: :delete_all
  maps_to_insales type: :insales_type

end
