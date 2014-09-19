class Collection < ActiveRecord::Base
  has_many :collects, dependent: :destroy
  has_many :products, through: :collects
  belongs_to :account

  maps_to_insales parent_id: :insales_parent_id
end
