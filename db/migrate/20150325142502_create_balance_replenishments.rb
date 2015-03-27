class CreateBalanceReplenishments < ActiveRecord::Migration
  def change
    create_table :balance_replenishments do |t|
      t.references :account, index: true, null: false
      t.integer :amount, null: false
      t.datetime :paid_at
      t.datetime :failed_at

      t.timestamps
    end
  end
end
