class RemoveCookiesFromOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :cookies
  end

  def down
    add_column :orders, :cookies, :string
  end
end
