class Product < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  # Рельса неважно валидирует булевские значения
  # false.blank? == true
  validates :available, :is_hidden, inclusion: [true, false]
  belongs_to :category
  belongs_to :account
  has_many :variants
  has_many :images

  maps_to_insales category_id: :insales_category_id

  scope :by_category_id, ->(category_id) { Category.find(category_id).nested_products.order(:category_id) }

end
