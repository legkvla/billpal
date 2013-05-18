module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoney
        class Return < ActiveMerchant::Billing::Integrations::Return
          include Common

          def initialize(post, options = {})
            requires!(options, :account, :secret)
            super
          end

          def item_id
            params['orderNumber']
          end

          def customer_id
            params['customerNumber']
          end

          def invoice_id
            params['invoiceId']
          end

          def action
            params['action']
          end

          def secret
            @options[:secret]
          end

          def account
            @options[:account]
          end

          def security_key
            params[ActiveMerchant::Billing::Integrations::YandexMoney.signature_parameter_name]
          end

          def acknowledge
            security_key.present? && security_key.upcase == generate_signature.upcase
          end

          def paid?
            acknowledge && action == 'PaymentSuccess'
          end

          def fail?
            acknowledge && action == 'PaymentFail'
          end
        end
      end
    end
  end
end
