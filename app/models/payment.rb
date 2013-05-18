class Payment < ActiveRecord::Base
  include Payments::Validations

  belongs_to :paymentable, polymorphic: true

  as_enum :kind, credit_card: 0, phone: 1, test: 9_999_999
  as_enum :payment_kind, paysio: 9_000

  monetize :amount_cents, as: :amount

  validate :amount_greater_that_zero

  state_machine :state, initial: :pending do
    around_transition do |payment, transition, block|
      ActiveRecord::Base.transaction do
        payment.reload

        block.() if payment.state.to_s == transition.from.to_s
      end
    end

    event :authorize do
      transition :pending => :authorization
    end

    event :failure do
      transition [:authorization, :pending] => :failed
    end

    event :cancel do
      transition [:authorization, :pending] => :canceled
    end

    event :refund do
      transition :paid => :refunded
    end

    event :chargeback do
      transition :pending => :returned
    end

    event :pay do
      transition [:canceled, :authorization, :pending] => :paid
    end

    after_transition on: :pay do |payment, _|
      payment.paymentable.pay!
    end
  end
end
