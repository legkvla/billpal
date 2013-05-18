module Payments::Validations
  def receiver_cant_be_sender
    if self.user_to_id == self.user_from_id
      errors.add(:amount, I18n.t('errors.payment.receiver_cant_be_sender'))
    end
  end

  def amount_greater_that_zero
    if self.amount.to_f <= 0.0 || self.original_amount.to_f <= 0.0
      errors.add(:amount, I18n.t('errors.payment.amount_greater_than_zero'))
    end
  end
end
