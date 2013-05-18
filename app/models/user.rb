class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable,
				 :trackable, :validatable, :confirmable, :omniauthable

	attr_accessible :email, :name, :password, :password_confirmation, :remember_me

	has_many :authorizations, :dependent => :destroy
  has_many :contacts, uniq: true
  has_many :payment_transfers, uniq: true
  has_many :balances, uniq: true

  after_create do
    self.contacts.create!({uid: self.id, kind: :internal, user_id: self.id}, without_protection: true)
    self.balances.create!({currency: :rub}, without_protection: true)
  end
end
