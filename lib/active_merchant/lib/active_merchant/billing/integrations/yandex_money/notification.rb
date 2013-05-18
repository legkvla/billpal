module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoney
        class Notification < ActiveMerchant::Billing::Integrations::Notification
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

          def security_key
            params[ActiveMerchant::Billing::Integrations::YandexMoney.signature_parameter_name]
          end

          def status
            if acknowledge
              if action == 'checkOrder'
                'authorization'
              elsif action == 'paymentAviso'
                'paid'
              end
            end
          end

          def amount
            BigDecimal.new(gross)
          end

          def gross
            params['orderSumAmount']
          end

          def currency_code
            params['orderSumCurrencyPaycash'].to_i
          end

          def secret
            @options[:secret]
          end

          def account
            @options[:account]
          end

          def paid?
            acknowledge && status == 'paid'
          end

          def shop_id
            params['shopId']
          end

          def action
            params['action']
          end

          alias_method :complete?, :paid?

          def authorization?
            acknowledge && account == shop_id && status == 'authorization'
          end

          def acknowledge
            security_key.upcase == generate_signature.upcase && valid_currency_code == currency_code
          end

          def get_time
            Time.now.iso8601
          end

          def success_response(*args)
            if authorization?
              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
<checkOrderResponse performedDatetime="#{get_time}"
code="0" invoiceId="#{invoice_id}" shopId="#{account}"/>}

              { xml: body }
            elsif paid?
              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
<paymentAvisoResponse performedDatetime="#{get_time}"
code="0" invoiceId="#{invoice_id}" shopId="#{account}"/>}

              { xml: body }
            else
              { nothing: true }
            end
          end

          def failure_response(message = 'failure')
            if action == 'checkOrder'
              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
<checkOrderResponse performedDatetime="#{get_time}"
code="100" invoiceId="#{invoice_id}" shopId="#{account}" message="#{message}" techMessage="#{message}" />}

              { xml: body }
            elsif action == 'paymentAviso'
              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
<paymentAvisoResponse performedDatetime="#{get_time}"
code="100" invoiceId="#{invoice_id}" shopId="#{account}" message="#{message}" techMessage="#{message}" />}

              { xml: body }
            else
              { nothing: true }
            end
          end

          private

          def valid_currency_code
            if ActiveMerchant::Billing::Base.integration_mode == :production
              643
            elsif ActiveMerchant::Billing::Base.integration_mode == :test
              10643
            end
          end
        end
      end
    end
  end
end
