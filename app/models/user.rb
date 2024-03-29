class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable

  attr_accessible :email, :name, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name

  has_many :authorizations, :dependent => :destroy
  has_many :contacts, uniq: true, :dependent => :destroy
  has_many :transfers, foreign_key: :from_user_id, uniq: true
  has_many :payments, uniq: true
  has_many :balances, uniq: true
  has_many :bills, foreign_key: :from_user_id, uniq: true
  has_many :invoices, foreign_key: :from_user_id, uniq: true
  has_many :notifications, uniq: true
  has_many :withdrawals, as: :withdrawable, uniq: true

  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: 'followed_id',
           class_name:  'Relationship',
           dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower


  after_create do
    self.contacts.create!({uid: self.id, kind: :internal, user_id: self.id}, without_protection: true)
    self.balances.create!({currency: :rub}, without_protection: true)

    #TODO
    self.contacts.create({uid: self.email, kind: :email, user_id: self.id}, without_protection: true)
  end

  before_validation do
    self.password_confirmation = self.password
  end

  def anonymous?
    self.persisted? && self.role == 'anonymous'
  end

  def balance
    self.balances.where(currency_cd: Balance.currencies(:rub)).first
  end

  def contact
    @contact ||= self.contacts.where(kind_cd: Contact.kinds(:internal), uid: self.id.to_s).first if self.persisted?
  end

  def create_transfer amount, contact_to_kind, contact_to_uid, payment_method
    amount = amount.to_money

    contract_to = Contact.where(kind_cd: Contact.kinds(contact_to_kind), uid: contact_to_uid).first
    unless contract_to.present?
      contract_to = Contact.create_with_user(contact_to_kind, contact_to_uid)
    end

    transfer = self.transfers.new(
        {
            amount: amount,
            from_contact_id: self.contact.id,
            to_user_id: contract_to.user_id,
            to_contact_id: contract_to.id
        }, without_protection: true)

    if transfer.valid?
      payment = self.payments.new(
          {
              amount: amount,
              paymentable: transfer,
              kind: payment_method,
              payment_kind: :paysio
          }, without_protection: true)

      if payment.valid? && transfer.save && payment.save
        charge = Paysio::Charge.create(
            amount: amount.to_f.round * 100, #FIX: for paysio
            payment_system_id: payment_method,
            order_id: payment.id,
            return_url: root_url,
            success_url: returns_paysio_url,
            failure_url: returns_paysio_url,
            currency_id: 'rur',
            description: "PaymentTransfer##{payment.id}")

        payment.update_column(:uid, charge.id)
        payment
      end
    end
	end

  def title
    'I am'
  end

  def notifications_count
    @notifications_count ||= self.notifications.count
  end

  def view_notifications!
    self.notifications.newest.update_all({viewed: true}, without_protection: true)
  end

	protected
	#def confirmation_required?
	#	false
	#end
end
