# This migration comes from insales_app_core_engine (originally 20140530111213)
class AddTariffDataToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :tariff_data, :json
  end
end
