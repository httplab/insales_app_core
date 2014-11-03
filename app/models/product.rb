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
  has_many :product_characteristics
  has_many :characteristics, through: :product_characteristics

  maps_to_insales category_id: :insales_category_id
  scope :by_category_id, ->(category_id) { Category.find(category_id).nested_products.order(:category_id) }

  def set_characteristics(ids)
    self.product_characteristics.where('product_characteristics.characteristic_id NOT IN (?)', ids).delete_all
    local_ids = self.product_characteristics.map(&:characteristic_id)
    ids_to_add = ids - local_ids

    ids_to_add.each do |id_to_add|
      self.product_characteristics.create(characteristic_id: id_to_add)
    end
  end

end
