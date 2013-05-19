class DeilyPenaltyToZero < ActiveRecord::Migration
  def change
    change_column_default :bills, :daily_penalty, 0
  end
end
