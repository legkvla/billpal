class AddFineFields < ActiveRecord::Migration
  def change
    add_column :bills, :daily_penalty, :integer, :null => true
  end
end
