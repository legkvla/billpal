class Contact < ActiveRecord::Base
  include ValidatorsHelper

  belongs_to :user

  as_enum :kind, internal: 0, phone: 1

  validates_presence_of :kind_cd, :user_id, :uid
  validates_uniqueness_of :uid, scope: [:kind_cd]

  def valid_phone_number?
    self.phone? && valid_phone?(self.uid)
  end
end
