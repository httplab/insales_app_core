class Product < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  # Рельса неважно валидирует булевские значения
  # false.blank? == true
  validates :available, :is_hidden, inclusion: [true, false]
  belongs_to :category, primary_key: :insales_id, foreign_key: :insales_category_id

  belongs_to :account

  has_many :variants, dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :images, dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :collects, dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :collections, through: :collects
  has_many :order_lines, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :product_characteristics, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :characteristics, through: :product_characteristics
  has_many :product_field_values, primary_key: :insales_id, foreign_key: :insales_product_id,
           dependent: :delete_all

  has_many :properties, through: :characteristics, primary_key: :insales_id, foreign_key: :insales_property_id

  maps_to_insales category_id: :insales_category_id
  scope :by_category_id, ->(category_id) { Category.find(category_id).nested_products.order(:category_id) }

  # def set_characteristics(ids)
  #   self.product_characteristics.where('product_characteristics.characteristic_id NOT IN (?)', ids).delete_all
  #   local_ids = self.product_characteristics.map(&:characteristic_id)
  #   ids_to_add = ids - local_ids

  #   ids_to_add.each do |id_to_add|
  #     self.product_characteristics.create(characteristic_id: id_to_add)
  #   end
  # end

end
