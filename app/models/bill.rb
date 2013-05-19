# Счет с различными филдами (auth only)

class Bill < ActiveRecord::Base
  attr_accessible :title, :description, :user_to, :amount_cents, :from_contact_id

  belongs_to :contact_to, class_name: 'Contact'
  belongs_to :contact_from, class_name: 'Contact'

  belongs_to :user_to, class_name: 'User'
  belongs_to :user_from, class_name: 'User'

  has_many :payments, as: :paymentable, uniq: true

  has_many :items

  monetize :amount_cents, as: :amount
end
