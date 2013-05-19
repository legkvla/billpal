class AddPayUntilToBills < ActiveRecord::Migration
  def change
    add_column :bills, :pay_until, :date
  end
end
