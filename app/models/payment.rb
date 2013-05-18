class Payment < ActiveRecord::Base
  include Payments::Validations

  belongs_to :payment_invoice

  as_enum :kind, credit_card: 0, phone: 1
  as_enum :payment_kind, paysio: 9000

  monetize :amount_cents, as: :amount

  validate :amount_greater_that_zero
  validate :receiver_cant_be_sender
end
