class ChangeDefaultNulls < ActiveRecord::Migration
  def change
    %w[to_user_id to_contact_id title description].each do |column|
      change_column_null :bills, column, true
    end
  end
end
