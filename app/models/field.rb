class Field < ActiveRecord::Base
  validates :account_id, :insales_id, :destiny, :office_title, :position, presence: true

  validates :active, :for_buyer, :obligatory, :show_in_checkout, :show_in_result,
  inclusion: [true, false]

  belongs_to :account

  maps_to_insales
end
