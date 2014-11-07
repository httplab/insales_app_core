class Category < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  has_many :products
  belongs_to :account
  belongs_to :parent, class_name: 'Category', foreign_key: :insales_parent_id, primary_key: :insales_id
  has_many :children, class_name: 'Category', foreign_key: :insales_parent_id, primary_key: :insales_id

  maps_to_insales parent_id: :insales_parent_id

  scope :top_level, ->{where('parent_id IS NULL')}
  scope :order_by_position, -> { order(:position) }

  def self.tree_hash
    top_level.map(&:subtree_hash)
  end

  def subtree_hash
    node = as_json
    node[:children] = children.map(&:subtree_hash)
    node
  end

  def hierarchy
    hierarchy = [self]
    category = parent

    while category do
      hierarchy.unshift category
      category = category.parent
    end

    hierarchy
  end

  def is_child_of?(category)
    hierarchy.include?(category)
  end

  def nested_products
    return Product.all if parent.nil?
    return products if children.empty?

    ids = children.order_by_position.pluck(:id)
    ids.unshift(id)
    Product.where(category_id: ids)
  end
end
