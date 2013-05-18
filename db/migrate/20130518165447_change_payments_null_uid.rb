class ChangePaymentsNullUid < ActiveRecord::Migration
  def change
    change_column_null :payments, :uid, false
  end
end
