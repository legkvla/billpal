class ChangePaymentsUidNull < ActiveRecord::Migration
  def change
    change_column_null :payments, :uid, true
  end
end
