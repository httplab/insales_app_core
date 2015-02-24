class AddAdditionalPricesToVariant < ActiveRecord::Migration
  def change
    add_column :variants, :additional_prices, :hstore
  end
end
