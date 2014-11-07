class FieldsValue < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_field_id, :insales_owner_id, :name, presence: true

  belongs_to :account
  belongs_to :field, primary_key: :insales_id, foreign_key: :insales_field_id

  maps_to_insales field_id: :insales_field_id,
                  owner_id: :insales_owner_id
end
