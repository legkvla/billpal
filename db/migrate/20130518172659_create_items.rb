class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.belongs_to :bill
      t.string :name, null: false
      t.integer :count, null: false
      t.decimal :unit_price, null: false, precision: 30, scale: 0
      t.timestamps
    end
  end
end
