class AddTariffDataToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :tariff_data, :json
  end
end
