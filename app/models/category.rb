class Category < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  has_many :products
  belongs_to :account
  belongs_to :parent, class_name: 'Category', foreign_key: :parent_id
  has_many :children, class_name: 'Category', foreign_key: :parent_id

  maps_to_insales parent_id: :insales_parent_id

  scope :top_level, ->{where('parent_id IS NULL')}

  def self.tree_hash
    top_level.map(&:subtree_hash)
  end

  def subtree_hash
    node = as_json
    node[:children] = children.map(&:subtree_hash)
    node
  end

end
