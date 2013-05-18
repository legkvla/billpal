class NotificationsMailer < ActionMailer::Base
  add_template_helper(MailerHelper)

  default from: 'noreply@billpay.ru'

  def transfer transfer_id
    mail(to: user.email, subject: '')
  end
end
