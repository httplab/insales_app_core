class Domain < ActiveRecord::Base
  validates :domain, :insales_id
  belongs_to :account

  maps_to_insales
end
