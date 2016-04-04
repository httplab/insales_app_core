class OptionValue < ActiveRecord::Base
  validates :account, :insales_id, :option_name_id, :title, presence: true

  belongs_to :account
  belongs_to :option_name

  maps_to_insales
end
