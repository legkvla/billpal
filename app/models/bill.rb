# Счет с различными филдами (auth only)

class Bill < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :title, :description, :to_user, :amount_cents, :from_contact_id, :items_attributes

  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  has_many :items

  accepts_nested_attributes_for :items, reject_if: proc {|attrs| attrs[:title].blank?}, allow_destroy: true

  monetize :amount_cents, as: :amount

  validates_presence_of :from_contact_id

  def create_payment(payment_method)
    if self.to_user and self.to_contact and self.amount_cents > 0 and self.state == "pending"
      params = {
          amount: amount_cents,
          paymentable: self,
          payment_kind: :paysio,
          kind: payment_method,
          user_id: to_user.id
      }

      payment = payments.new(
          params, without_protection: true
      )

      if payment.valid? && payment.save
        charge = Paysio::Charge.create(
            amount: amount_cents.to_f.round * 100, #FIX: for paysio
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
end
