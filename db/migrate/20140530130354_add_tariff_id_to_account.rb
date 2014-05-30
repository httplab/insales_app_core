class AddTariffIdToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :tariff_id, :string
  end
end
