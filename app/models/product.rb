class Product < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  # Рельса неважно валидирует булевские значения
  # false.blank? == true
  validates :available, :is_hidden, inclusion: [true, false]
  belongs_to :category
  belongs_to :account
  has_many :variants, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :collects, dependent: :destroy
  has_many :collections, through: :collects
  has_many :order_lines

  maps_to_insales category_id: :insales_category_id
  scope :by_category_id, ->(category_id) { Category.find(category_id).nested_products.order(:category_id) }
end
