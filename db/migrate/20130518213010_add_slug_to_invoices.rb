class AddSlugToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :slug, :string
  end
end
