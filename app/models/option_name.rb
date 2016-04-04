class OptionName < ActiveRecord::Base
  validates :account, :insales_id, :title, presence: true

  belongs_to :account
  has_many :option_values, dependent: :destroy

  maps_to_insales
end
