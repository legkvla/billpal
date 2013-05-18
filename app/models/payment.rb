class Payment < ActiveRecord::Base
  include Payments::Validations

  belongs_to :paymentable, polymorphic: true

  as_enum :kind, credit_card: 0, phone: 1, test: 9_999_999
  as_enum :payment_kind, paysio: 9_000

  monetize :amount_cents, as: :amount

  validate :amount_greater_that_zero
end
