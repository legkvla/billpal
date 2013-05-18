class Api::V1::VerificatorsController < ApiController
  include ValidatorsHelper

  def verificate
    if params[:phone_number].present?
      session[:phone_numbers] ||= {}
      if valid_phone?(params[:phone_number])
        phone_number = parse_phone_number(params[:phone_number])
        if session[:phone_numbers][phone_number].present?
          render json: {status: 'already sent'}
        else
          code = (Random.rand(899_999) + 100_000).to_s
          session[:phone_numbers][phone_number] = code
          #TODO
          #SendSms.perform_async(phone_number, I18n.t('verificators.phone_number', code: code))

          render json: {status: 'ok', code: code}
        end
      else
        render json: {status: 'invalid phone number'}, status: 500
      end
    elsif params[:email].present?
      session[:emails] ||= {}
      if valid_email?(params[:email])
        email = params[:email]
        if session[:emails][email].present?
          render json: {status: 'already sent'}
        else
          slug = SecureRandom.base64(135)
          session[:emails][email] = slug
          NotificationsMailer.email_verification_slug(email, slug).deliver!

          render json: {status: 'ok', slug: slug}
        end
      else
        render json: {status: 'invalid email'}, status: 500
      end
    end
  end

  def verification_code
    if params[:code].present? && params[:phone_number].present? && valid_phone?(params[:phone_number])
      phone_number = parse_phone_number(params[:phone_number])
      code = session[:phone_numbers][phone_number].to_s

      if code.present? && params[:code].to_s == code
        # TODO: investigate not removing phone number
        session[:phone_numbers].delete phone_number
        contact = Contact.where(uid: phone_number, kind_cd: Contact.kinds(:internal)).first

        unless contact.present?
          scope = if current_user.present?
                    current_user.contacts.scoped
                  else
                    password = "#{SecureRandom.hex}_#{(Random.rand(8_999_999) + 1_000_000)}"
                    new_user = User.create!(
                        {
                            email: "#{SecureRandom.hex}@internal.anonymous",
                            password: password,
                            password_confirmation: password,
                            role: 'anonymous'
                        }, without_protection: true)

                    new_user.contacts.scoped
                  end

          contact = scope.create!({kind: :internal, uid: phone_number}, without_protection: true)
        end

        sign_in(contact.user) unless current_user.present?

        render json: {status: 'ok'}
      else
        render json: {status: 'invalid code'}, status: 500
      end
    else
      render json: {status: 'invalid phone number or code'}, status: 500
    end
  end
end
