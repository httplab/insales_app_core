class Product < ActiveRecord::Base
  validates :account_id, :insales_id, :title, :available, :is_hidden, presence: true
  belongs_to :category
  belongs_to :account
  has_many :variants
  has_many :images, class_name: 'Product::Image'

  maps_to_insales
  map_insales_fields category_id: :insales_category_id
end
