class FieldsValue < ActiveRecord::Base
  validates :account_id, :insales_id, :field_id, :insales_field_id, :owner_id, :name, presence: true

  belongs_to :account
  belongs_to :field

  maps_to_insales field_id: :insales_field_id
end
