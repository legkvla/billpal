class Bill < ActiveRecord::Base
  belongs_to :contact_to, class_name: 'Contact'
  belongs_to :contact_from, class_name: 'Contact'

  belongs_to :user_to, class_name: 'User'
  belongs_to :user_from, class_name: 'User'

  monetize :amount_cents, as: :amount
end
