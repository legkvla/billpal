class Contact < ActiveRecord::Base
  include ValidatorsHelper

  belongs_to :user

  as_enum :kind, internal: 0, phone: 1

  validates_presence_of :kind_cd, :user_id, :uid
  validates_uniqueness_of :uid, scope: [:kind_cd]

  def valid_phone_number?
    self.phone? && valid_phone?(self.uid)
  end

  def self.create_with_user(kind, uid)
    password = "#{SecureRandom.hex}_#{(Random.rand(8_999_999) + 1_000_000)}"
    new_user = User.create!(
        {
            email: "#{SecureRandom.hex}@internal.anonymous",
            password: password,
            password_confirmation: password,
            role: 'anonymous'
        }, without_protection: true)

    new_user.contacts.create!({kind_cd: Contact.kinds(kind), uid: uid}, without_protection: true)
  end
end
