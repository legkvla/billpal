class InheritBillsFromInvoices < ActiveRecord::Migration
  def change
    drop_table :bills

    create_table :bills, options: 'INHERITS (invoices)' do |t|
      t.decimal :amount_cents, null: false, precision: 30, scale: 0
      t.integer :from_user_id
      t.integer :from_contact_id, null: false
      t.integer :to_user_id
      t.integer :to_contact_id, null: false
      t.string :state, null: false, default: 'pending'

      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end
end
