class Api::V1::VerificatorsController < ApiController
  include ValidatorsHelper

  def verificate
    session[:phone_numbers] ||= {}

    if params[:phone_number].present? && valid_phone?(params[:phone_number])
      phone_number = params[:phone_number]
      if session[:phone_numbers][phone_number].present?
        render json: {status: 'already sent'}, status: 500
      else
        code = Random.rand(899_999) + 100_000
        session[:phone_numbers][phone_number] = code
        SendSms.perform_async(phone_number, I18n.t('verificators.phone_number', code: code))

        render json: {status: 'ok'}
      end
    end
  end

  def verification_code
    if params[:code].present?

    end
  end
end
