class CreateSentSms < ActiveRecord::Migration
  def change
    create_table :sent_sms do |t|
      t.integer :user_id
      t.integer :contact_id, null: false
      t.text :message, null: false
      t.string :phone_number, null: false
      t.string :uid, null: false

      t.timestamps
    end
  end
end
