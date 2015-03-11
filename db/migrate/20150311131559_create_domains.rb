class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.integer :insales_id, null: false
      t.integer :account_id, null: false
      t.boolean :main, null: false, default: false
      t.string :domain, null: false

      t.timestamps
    end

    add_index :domains, :insales_id, unique: true
    add_index :domains, :account_id
  end
end
