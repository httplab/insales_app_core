class Property < ActiveRecord::Base
  validates :account_id, :insales_id, :title, presence: true
  belongs_to :account
  has_many :characteristics, primary_key: :insales_id, foreign_key: :insales_property_id
  maps_to_insales
end
