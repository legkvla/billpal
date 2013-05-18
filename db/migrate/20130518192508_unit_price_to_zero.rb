class UnitPriceToZero < ActiveRecord::Migration
  def change
    change_column_default :items, :unit_price, 0
  end
end
