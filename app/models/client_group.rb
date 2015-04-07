class ClientGroup < ActiveRecord::Base
  belongs_to :account
  has_many :clients, primary_key: :insales_id, foreign_key: :insales_client_group_id

  validates :account_id, :title, presence: true

  maps_to_insales
end
