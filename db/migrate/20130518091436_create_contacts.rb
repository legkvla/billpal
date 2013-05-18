class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :uid, null: false
      t.text :params
      t.integer :kind_cd, null: false
      t.integer :user_id, null: false, default: 0

      t.timestamps
    end
  end
end
