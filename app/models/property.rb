class Property < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  belongs_to :account
  has_many :characteristics
  maps_to_insales
end
