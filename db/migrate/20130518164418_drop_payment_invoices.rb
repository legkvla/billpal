class DropPaymentInvoices < ActiveRecord::Migration
  def change
    drop_table :payment_invoices
  end
end
