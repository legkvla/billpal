class SentSms < ActiveRecord::Base
  attr_accessible :contact_id, :message, :phone_number, :user_id
end
