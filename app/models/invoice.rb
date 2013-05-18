# Просто счет (просить деньги)

class Invoice < ActiveRecord::Base
  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true
  has_many :withdrawals, as: :withdrawable, uniq: true

  monetize :amount_cents, as: :amount

  before_create do
    self.slug = SecureRandom.base64(135)
  end
end
