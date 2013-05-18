class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :contacts, uniq: true
  has_many :payment_transfers, uniq: true
  has_many :payments, uniq: true
  has_many :balances, uniq: true

  after_create do
    self.contacts.create!({uid: self.id, kind: :internal, user_id: self.id}, without_protection: true)
    self.balances.create!({currency: :rub}, without_protection: true)
  end

  def anonymous?
    self.persisted? && self.role == 'anonymous'
  end

  def balance
    self.balances.where(currency_cd: Balance.currencies(:rub)).first
  end

  def create_payment amount, contact_to_kind, contact_to_uid, payment_method
    payment = self.payments.build
    contact = Contact.find(uid: contact_to_uid, kind_cd: Contact.kinds(contact_to_kind)).first
    unless contact.present?

    end

    payment
  end
end
