class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id, null: false
      t.text :text, null: false
      t.boolean :viewed, null: false, default: false

      t.timestamps
    end
  end
end
