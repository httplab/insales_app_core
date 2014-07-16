# This migration comes from insales_app_core_engine (originally 20140530130354)
class AddTariffIdToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :tariff_id, :string
  end
end
