class Withdrawal < ActiveRecord::Base
  attr_accessible :kind_cd, :params, :payment_kind_cd, :state, :uid, :withdrawable_id, :withdrawable_type

  belongs_to :withdrawable, polymorphic: true
end
