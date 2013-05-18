class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.integer :withdrawable_id, null: false
      t.string :withdrawable_type, null: false
      t.string :state, null: false, default: 'pending'
      t.string :uid
      t.integer :kind_cd, null: false
      t.integer :payment_kind_cd, null: false
      t.text :params

      t.timestamps
    end
  end
end
