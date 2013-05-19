class AddAmountCentsToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :amount_cents, :decimal, null: false, precision: 30, scale: 0
  end
end
