class PaymentInvoice < ActiveRecord::Base
  attr_accessible :from_contact_id, :from_user_id, :invoiceable_id, :invoiceable_type, :to_contact_id, :to_user_id
end
