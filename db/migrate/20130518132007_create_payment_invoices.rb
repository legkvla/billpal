class CreatePaymentInvoices < ActiveRecord::Migration
  def change
    create_table :payment_invoices do |t|
      t.decimal :amount_cents, null: false, precision: 30, scale: 0
      t.integer :invoiceable_id, null: false
      t.string :invoiceable_type, null: false
      t.integer :from_user_id, null: false
      t.integer :from_contact_id, null: false
      t.integer :to_user_id, null: false
      t.integer :to_contact_id, null: false

      t.timestamps
    end
  end
end
