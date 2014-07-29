class Client < ActiveRecord::Base
  validates :account_id, :insales_id, :name, presence: true
  belongs_to :account
  has_many :orders
  maps_to_insales
end
