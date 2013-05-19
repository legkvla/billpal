# Просто счет (просить деньги)

class Invoice < ActiveRecord::Base

	attr_accessible :amount_cents, :from_user_id, :from_contact_id, :to_user_id, :to_contact_id, :state

  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  monetize :amount_cents, as: :amount

  after_save do
    from_user.relationships.build(followed_id: self.to_user_id) if from_user.present? && to_user.present?
  end

  before_create do
    self.slug = SecureRandom.base64(135)
  end
end
