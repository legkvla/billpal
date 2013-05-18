module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Platron
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include Common

          mapping :account, 'pg_merchant_id'
          mapping :amount, 'pg_amount'
          mapping :order, 'pg_order_id'
          mapping :lifetime, 'pg_lifetime'
          mapping :customer, {
              :email => 'pg_user_email',
              :contact_email => 'pg_user_contact_email',
              :phone => 'pg_user_phone'
          }
          mapping :payment_system, 'pg_payment_system'
          mapping :description, 'pg_description'
          mapping :salt, 'pg_salt'
          mapping :ip, 'pg_user_ip'

          mapping :return_refund_url, 'pg_refund_url'
          mapping :return_result_url, 'pg_result_url'
          mapping :return_success_url, 'pg_success_url'
          mapping :return_failure_url, 'pg_failure_url'

          def initialize(order, account, options = {})
            @_secret = options.delete(:secret)

            super

            @fields[mappings[:salt]] ||= pg_salt
            @fields[mappings[:description]] ||= @fields[mappings[:order]]
          end

          def params
            @fields
          end

          def secret
            @_secret
          end

          def account
            params[mappings[:account]]
          end

          def form_fields
            @fields.merge(ActiveMerchant::Billing::Integrations::Platron.signature_parameter_name => generate_signature_string('payment.php'))
          end
        end
      end
    end
  end
end
