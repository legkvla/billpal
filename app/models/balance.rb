class Balance < ActiveRecord::Base
  belongs_to :user

  as_enum :currency, usd: 840, euro: 978, rub: 643

  monetize :amount_cents, as: :amount
end
