class NotificationsMailer < ActionMailer::Base
  default from: 'noreply@billpay.ru'

  def transfer transfer_id
    @transfer = Transfer.find(transfer_id)
    @user = @transfer.to_user
    mail(to: @user.email, subject: I18n.t('notifications.transfer'))
  end

  def email_verification_slug email, slug
    @slug = slug
    mail(to: email, subject: I18n.t('notifications.email_verification_code'))
  end
end
