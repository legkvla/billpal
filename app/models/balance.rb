class Balance < ActiveRecord::Base
  attr_accessible :amount_cents, :currency_cd, :user_id
end
