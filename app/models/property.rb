class Property < ActiveRecord::Base
  belongs_to :account
  has_many :characteristics, primary_key: :insales_id, foreign_key: :insales_property_id
  has_many :products,  through: :characteristics, primary_key: 'insales_product_id', foreign_key: :insales_id

  validates :account_id, :insales_id, :title, presence: true
  maps_to_insales
end
