class Contact < ActiveRecord::Base
  include ValidatorsHelper

  belongs_to :user

  as_enum :kind, internal: 0, phone: 1

  validates_presence_of :kind_cd, :user_id, :uid
  validates_uniqueness_of :uid, scope: [:kind_cd]

  def valid_phone_number?
    self.phone? && valid_phone?(self.uid)
  end

  def self.create_user_or_link_with_them
      scope = if current_user.present?
                current_user.contacts.scoped
              else
                password = "#{SecureRandom.hex}_#{(Random.rand(8_999_999) + 1_000_000)}"
                new_user = User.create!({
                                            email: "#{SecureRandom.hex}@internal.anonymous",
                                            password: password,
                                            password_confirmation: password,
                                            role: 'anonymous'
                                        }, without_protection: true)

                sign_in(new_user)

                new_user.contacts.scoped
              end

      scope.create!({kind: :internal, uid: phone_number}, without_protection: true)
  end
end
