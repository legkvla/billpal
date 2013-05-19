# Счет с различными филдами (auth only)

class Bill < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :title, :description, :to_user, :to_user_id,
                  :amount_cents, :from_contact_id, :items_attributes, :daily_penalty, :to_user_attributes

  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  has_many :items

  accepts_nested_attributes_for :items, reject_if: proc {|attrs| attrs[:title].blank?}, allow_destroy: true
  accepts_nested_attributes_for :to_user

  monetize :amount_cents, as: :amount

  validates_presence_of :from_contact_id
  validates :daily_penalty, :numericality => {:greater_than_or_equal_to => 0}

  before_save :update_state!

  after_save do
    from_user.relationships.build(followed_id: self.to_user_id) if from_user.present? && to_user.present?
  end

  def fine
    daily_penalty.to_i.to_f / 100 * amount_cents.to_i * overdue_days
  end

  def to_user_attributes=(attributes)
    self.to_user = User.create!(attributes.merge(:password => "soclose!"))
    self.to_contact = to_user.contact
  end

  def overdue_days
    days = (Date.today - (pay_until || Date.today)).to_i
    if days > 0
      days
    else
      0
    end
  end

  def create_payment(payment_method)
    if self.to_user and self.to_contact and self.amount_cents > 0 and self.state == "exposed"
      params = {
          amount_cents: amount_cents + fine,
          paymentable: self,
          payment_kind: :paysio,
          kind: payment_method,
          user_id: to_user.id
      }

      payment = payments.new(
          params, without_protection: true
      )

      if payment.valid? && payment.save
        Paysio::Charge.create(
            amount: payment.amount_cents, #FIX: for paysio
            payment_system_id: payment_method,
            order_id: payment.id,
            return_url: root_url,
            success_url: returns_paysio_url,
            failure_url: returns_paysio_url,
            currency_id: 'rur',
            description: "PaymentBill##{payment.id}")
      else
        nil
      end
    end
  end

  def pay!
    from_user.balance.update_attribute(:amount_cents, from_user.balance.amount_cents + amount_cents)
    update_attribute(:state, "paid")
  end

  def cancel!
    update_attribute(:state, "canceled")
  end

  def direction user
    if user == to_user
      "in"
    elsif user == from_user
      "out"
    else
      nil
    end
  end

  private

  def update_state!
    if state == "pending" && !to_user.blank? && !to_contact.blank?
      self.state = "exposed"
    end
  end
end
