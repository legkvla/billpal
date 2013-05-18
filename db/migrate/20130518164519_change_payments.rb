class ChangePayments < ActiveRecord::Migration
  def change
    remove_column :payments, :payment_invoice_id

    add_column :payments, :paymentable_id, :integer, null: false
    add_column :payments, :paymentable_type, :string, null: false
  end
end
