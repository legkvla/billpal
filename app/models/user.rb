class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable,
				 :trackable, :validatable, :confirmable, :omniauthable

	attr_accessible :email, :name, :password, :password_confirmation, :remember_me

	has_many :authorizations, :dependent => :destroy
  has_many :contacts, uniq: true
  has_many :payment_transfers, uniq: true
  has_many :payment_invoices, foreign_key: :from_user_id, uniq: true
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

  def contract
    @contract ||= self.contracts.where(kind_cd: Contact.kinds(:internal), uid: self.id).first if self.persisted?
  end

  def create_payment_transfer amount, contact_to_kind, contact_to_uid, payment_method
    amount = amount.to_money

    contact = Contact.find(uid: contact_to_uid, kind_cd: Contact.kinds(contact_to_kind)).first
    unless contact.present?
      contract_to = Contact.create_with_user(contact_to_kind, contact_to_uid)
    end

    payment_transfer = self.payment_transfers.new(
        {
            amount: amount,
            from_contact_id: self.contact.id,
            to_user_id: contract_to.user_id,
            to_contact_id: contract_to.id
        }, without_protection: true)

    if payment_transfer.present?
      payment_invoice = self.payment_invoices.new(
          {
              amount: amount,
              invoiceable: payment_transfer,
              from_contact_id: self.contact.id,
              to_user_id: contract_to.user_id,
              to_contact_id: contract_to.id
          }, without_protection: true)

      if payment_invoice.valid? && payment_transfer.valid? && payment_transfer.save && payment_invoice.save
        charge = Paysio::Charge.create(
            amount: amount.to_f,
            payment_system_id: payment_method,
            description: "PaymentTransfer##{payment_transfer.id}")

        payment_invoice.payments.create(
            {
                amount: amount,
                uid: charge.id
            }, without_protection: true)
      end
    #else
    #  payment_transfer
    end
  end
end
