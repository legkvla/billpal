class ChangeDefaultValues < ActiveRecord::Migration
  def change
    change_column_default :balances, :amount_cents, 0
  end
end
