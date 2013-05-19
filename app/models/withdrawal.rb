class Withdrawal < ActiveRecord::Base
  extend ActiveMerchant::Billing

  attr_accessible :kind_cd, :params, :payment_kind_cd, :state, :uid, :withdrawable_id, :withdrawable_type

  belongs_to :withdrawable, polymorphic: true

  as_enum :kind, credit_card: 0, phone: 1, test: 9_999_999
  as_enum :payment_kind, just_gateway: 9_001

  #TODO: hack but it's fast
  before_save do
    gateway = JustGateway.new(login: Settings.just_gateway.login, secret: Settings.just_gateway.secret)
    self.uid = gateway.make_payment(self.amount.to_f, self.kind, self.params)['result']
  end

  #state_machine :state, initial: :pending do
  #  around_transition do |payment, transition, block|
  #    ActiveRecord::Base.transaction do
  #      payment.reload
  #
  #      block.() if payment.state.to_s == transition.from.to_s
  #    end
  #  end
  #
  #  event :authorize do
  #    transition :pending => :authorization
  #  end
  #
  #  event :failure do
  #    transition [:authorization, :pending] => :failed
  #  end
  #
  #  event :cancel do
  #    transition [:authorization, :pending] => :canceled
  #  end
  #
  #  event :refund do
  #    transition :paid => :refunded
  #  end
  #
  #  event :chargeback do
  #    transition :pending => :returned
  #  end
  #
  #  event :pay do
  #    transition [:canceled, :authorization, :pending] => :paid
  #  end
  #
  #  after_transition on: :pay do |payment, _|
  #    payment.paymentable.pay!
  #  end
  #end
end
