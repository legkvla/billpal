class PaymentTransfer < ActiveRecord::Base
  include Payments::Validations

  belongs_to :contact_to, class_name: 'Contact'
  belongs_to :contact_from, class_name: 'Contact'

  belongs_to :user_to, class_name: 'User'
  belongs_to :user_from, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  validate :amount_greater_that_zero
  validate :receiver_cant_be_sender

  monetize :amount_cents, as: :amount
end
