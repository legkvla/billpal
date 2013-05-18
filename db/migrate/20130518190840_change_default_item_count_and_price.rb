class ChangeDefaultItemCountAndPrice < ActiveRecord::Migration
  def change
    change_column_default :items, :count, 1
    change_column :items, :unit_price, :decimal, :precision => 30, :scale => 0, :null => true
    change_column :items, :amount_cents, :decimal, :precision => 30, :scale => 0, :null => false, :default => 0
  end
end
