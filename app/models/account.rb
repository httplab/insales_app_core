class Account < ActiveRecord::Base
  validates :insales_id, :insales_password, :insales_subdomain, presence: true
  validates :insales_id, :insales_subdomain, uniqueness: true
end

