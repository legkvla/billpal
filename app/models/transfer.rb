# Перевод (я перевожу свои деньги кому-то)

class Transfer < ActiveRecord::Base
  include Payments::Validations

  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true
  has_many :withdrawals, as: :withdrawable, uniq: true

  validate :amount_greater_that_zero
  validate :receiver_cant_be_sender

  monetize :amount_cents, as: :amount

  before_create do
    self.slug = SecureRandom.base64(135) if self.to_contact.email?
  end

  state_machine :state, initial: :pending do
    around_transition do |transfer, transition, block|
      ActiveRecord::Base.transaction do
        transfer.reload

        block.() if transfer.state.to_s == transition.from.to_s
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

    event :withdrawal do
      transition paid: :withdrawaled
    end

    after_transition on: :pay do |transfer, _|
      user = transfer.to_user
      if user.anonymous?
        contact = transfer.to_contact
        if contact.email?
          NotificationsMailer.transfer(transfer.id).deliver!
        elsif contact.phone?

        end
      else

      end
    end
  end
end
