class AddSlugToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :slug, :string
  end
end
