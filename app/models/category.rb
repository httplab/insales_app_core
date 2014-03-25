class Category < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  has_many :products
  belongs_to :account

  maps_to_insales parent_id: :insales_parent_id
end
