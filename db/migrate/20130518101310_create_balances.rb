class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.integer :user_id, null: false
      t.decimal :amount_cents, null: false, precision: 30, scale: 0
      t.integer :currency_cd, null: false

      t.timestamps
    end
  end
end
