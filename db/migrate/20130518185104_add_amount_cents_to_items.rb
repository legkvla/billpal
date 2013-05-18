class AddAmountCentsToItems < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.decimal :amount_cents, null: false, precision: 30, scale: 0
    end
  end
end
