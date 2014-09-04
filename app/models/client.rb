class Client < ActiveRecord::Base
  validates :account_id, :insales_id, :name, presence: true
  belongs_to :account
  has_many :orders

  def full_name
    [name, middlename, surname].compact.join(' ')
  end

  maps_to_insales
end