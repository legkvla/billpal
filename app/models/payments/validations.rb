module Payments::Validations
  def receiver_cant_be_sender
    if self.to_user_id == self.from_user_id
      errors.add(:from_user_id, I18n.t('errors.payment.receiver_cant_be_sender'))
    end
  end

  def amount_greater_that_zero
    if self.amount.to_f <= 0.0
      errors.add(:amount, I18n.t('errors.payment.amount_greater_than_zero'))
    end
  end
end
