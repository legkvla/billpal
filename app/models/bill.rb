# Счет с различными филдами (auth only)

class Bill < ActiveRecord::Base
  attr_accessible :title, :description, :to_user, :amount_cents, :from_contact_id

  belongs_to :to_contact, class_name: 'Contact'
  belongs_to :from_contact, class_name: 'Contact'

  belongs_to :to_user, class_name: 'User'
  belongs_to :form_user, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  has_many :items

  monetize :amount_cents, as: :amount
end
