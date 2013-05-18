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
  has_many :balances, uniq: true

  after_create do
    self.contacts.create!({uid: self.id, kind: :internal, user_id: self.id}, without_protection: true)
    self.balances.create!({currency: :rub}, without_protection: true)
  end
end
