module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Uniteller
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include Common

          mapping :account, 'Shop_IDP'
          mapping :amount, 'Subtotal_P'
          mapping :order, 'Order_IDP'
          mapping :lifetime, 'Lifetime'
          mapping :customer, {
              :id => 'Customer_IDP',
              :email => 'Email'
          }
          mapping :card, 'Card_IDP'
          mapping :mean_type, 'MeanType'
          mapping :emoney_type, 'EMoneyType'

          mapping :pre_authentication, 'Preauth'

          mapping :return_success_url, 'URL_RETURN_OK'
          mapping :return_failure_url, 'URL_RETURN_NO'

          def initialize(order, account, options = {})
            @_secret = options.delete(:secret)

            super
          end

          def params
            @fields
          end

          def secret
            @_secret
          end

          def shop_idp
            params[mappings[:account]]
          end

          def form_fields
            @fields.merge(ActiveMerchant::Billing::Integrations::Uniteller.signature_parameter_name => generate_signature)
          end
        end
      end
    end
  end
end
