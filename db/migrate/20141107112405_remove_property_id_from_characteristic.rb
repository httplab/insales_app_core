class RemovePropertyIdFromCharacteristic < ActiveRecord::Migration
  def change
    remove_column :characteristics, :property_id, :integer
  end
end
