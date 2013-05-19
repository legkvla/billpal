class SendSms
  include Sidekiq::Worker

  def perform phone_number, message
    if phone_number.present? && message.present?
      result = MultiXml.parse connection.post('/smw/aisms', {
          user: Settings.sms.user,
          pass: Settings.sms.password,
          action: 'post_sms',
          message: message,
          target: phone_number
      }).body

      if result['output'].present? && result['output']['result'].present? &&
          result['output']['result']['sms'].present? && result['output']['result']['sms']['id'].present?

        SendSms.create!(
            {
                phone_number: phone_number,
                message: message,
                contact_id: contact_id,
                user_id: contact.user_id,
                uid: result['output']['result']['sms']['id']
            }, without_protection: true)
      end
    end
  end

  private

  def connection
    Faraday.new(url: 'https://smpp.alfa-sms.ru', ssl: {verify: false}) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
    end
  end
end