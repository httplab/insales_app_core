class Field < ActiveRecord::Base
  # Использовть для этого слово Destiny придумал не я, так было в Insales.
  DESTINY_SHIPPING_ADDRESS = 1
  DESTINY_CLIENT = 2
  DESTINY_ORDER = 3

  validates :account_id, :insales_id, :destiny, :office_title, :position, presence: true

  validates :active, :for_buyer, :obligatory, :show_in_checkout, :show_in_result,
  inclusion: [true, false]

  scope :by_destiny, ->(destiny) { where(destiny: destiny) }
  scope :for_shipping_address, -> { where(destiny: DESTINY_SHIPPING_ADDRESS) }
  scope :for_client, -> { where(destiny: DESTINY_CLIENT) }
  scope :for_order, -> { where(destiny: DESTINY_ORDER) }

  belongs_to :account

  maps_to_insales
end
