class Client < ActiveRecord::Base
  validates :account_id, :insales_id, :name, :surname, :email, :phone, presence: true
  belongs_to :account
  has_many :fields_values, -> { joins(:field).where('fields.destiny = 3') }, class_name: FieldsValue, foreign_key: :owner_id

  maps_to_insales
end
