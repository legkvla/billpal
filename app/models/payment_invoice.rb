class PaymentInvoice < ActiveRecord::Base
  include Payments::Validations

  belongs_to :invoiceable

  has_many :payments, uniq: true

  validate :amount_greater_that_zero
  validate :receiver_cant_be_sender

  monetize :amount_cents, as: :amount
end
