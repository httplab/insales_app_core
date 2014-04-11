class AddCookiesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :cookies, :hstore
  end
end
