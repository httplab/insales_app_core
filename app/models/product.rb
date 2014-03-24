class Product < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  # Рельса неважно валидирует булевские значения
  # false.blank? == true
  validates :available, :is_hidden, inclusion: [true, false]
  belongs_to :category
  belongs_to :account
  has_many :variants
  has_many :images, class_name: 'Product::Image'

  maps_to_insales
  map_insales_fields category_id: :insales_category_id
end
