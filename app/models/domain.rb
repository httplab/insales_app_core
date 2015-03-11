class Domain < ActiveRecord::Base
  validates :domain, :insales_id, presence: true
  belongs_to :account

  maps_to_insales
end
