class Payment < ActiveRecord::Base
  belongs_to :payment_invoice

  as_enum :kind, credit_card: 0, phone: 1
  as_enum :payment_kind, paysio: 9000
end
