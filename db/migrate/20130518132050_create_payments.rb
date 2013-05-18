class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payment_invoice_id, null: false
      t.decimal :amount_cents, null: false, precision: 30, scale: 0
      t.string :state, null: false, default: 'pending'
      t.string :uid, null: false
      t.integer :kind_cd, null: false
      t.integer :payment_kind_cd, null: false
      t.text :params

      t.timestamps
    end
  end
end
