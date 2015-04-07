class Client < ActiveRecord::Base
  validates :account_id, :insales_id, :name, presence: true
  belongs_to :account
  belongs_to :client_group, primary_key: :insales_id, foreign_key: :insales_client_group_id
  has_many :orders, primary_key: :insales_id, foreign_key: :insales_client_id

  def full_name
    [name, middlename, surname].compact.join(' ')
  end

  maps_to_insales client_group_id: :insales_client_group_id
end
