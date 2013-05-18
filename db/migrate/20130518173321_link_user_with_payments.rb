class LinkUserWithPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.integer :user_id, null: false
    end
  end
end
