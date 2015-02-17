class Collection < ActiveRecord::Base
  has_many :collects, dependent: :destroy, primary_key: :insales_id, foreign_key: :insales_collection_id
  has_many :products, through: :collects
  belongs_to :account
  belongs_to :parent, class_name: 'Collection', primary_key: 'insales_id', foreign_key: 'insales_parent_id'
  has_many :children, class_name: 'Collection',  primary_key: 'insales_id', foreign_key: 'insales_parent_id'

  maps_to_insales parent_id: :insales_parent_id

  def path
    prefix = parent.path if parent.present?
    "#{prefix}/#{title}"
  end
end
