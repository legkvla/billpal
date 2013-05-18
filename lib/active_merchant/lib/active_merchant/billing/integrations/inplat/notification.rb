# encoding: utf-8

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Inplat
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include Common

          FAULT_CODES = %w[error incorrect_request already_paid break out_of_stock]

          def initialize(post, options = {})
            @options = options
            empty!
            @params = parse_xml(post)
          end

          def item_id
            params[:payment_id] if params[:payment_id].to_i > 0
          end

          def account
            params[:account]
          end

          def currency_code
            params[:currency].to_i
          end

          def status
            if paid?
              'paid'
            elsif canceled?
              'canceled'
            elsif contract?
              'authorization'
            end
          end

          def reg_data
            @reg_data ||= HashWithIndifferentAccess.new parse_reg_data(params[:payee_reg_data])
          end

          def user_params
            @user_params ||= HashWithIndifferentAccess.new parse_reg_data(params[:user_params])
          end

          def amount
            BigDecimal.new(gross.presence || '0')
          end

          def gross
            params[:sum].presence || user_params[:sum]
          end

          def repeat?
            params[:is_repeat]
          end

          def demo?
            params[:demo]
          end

          def contract?
            acknowledge && @key == :payment_contract
          end

          def paid?
            currency_valid = valid_currency_code == currency_code || currency_code.zero?

            acknowledge && @key == :payment_authorization && currency_valid
          end

          alias_method :complete?, :paid?

          def canceled?
            acknowledge && @key == :payment_cancellation
          end

          def acknowledge
            if ActiveMerchant::Billing::Base.integration_mode == :production
              !demo? && @key.present?
            else
              @key.present?
            end
          end

          def success_authorization_response(order_id, user_info)
            if paid?
              success_xml = CGI.escape_html(%Q{<?xml version="1.0" encoding="UTF-8"?>
                <success>
                  <param id="orderID" ref="orderID" label="Номер заказа">#{order_id}</param>
                  <param id="userInfo" ref="userInfo" label="Описание платежа для Клиента">#{user_info}</param>
                </success>})

              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
                <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:PaycashShopService" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                  <SOAP-ENV:Body>
                    <ns1:PaymentAuthorizationResponse>
                      <ReplyResource xsi:type="xsd:string">#{success_xml}</ReplyResource>
                      <ReplyResourceIsFailure xsi:type="xsd:boolean">false</ReplyResourceIsFailure>
                    </ns1:PaymentAuthorizationResponse>
                  </SOAP-ENV:Body>
                </SOAP-ENV:Envelope>}

              { xml: body }
            else
              { nothing: true, status: 500 }
            end
          end

          def success_cancelation_response
            if canceled?
              body = '<?xml version="1.0" encoding="UTF-8"?>
                <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:PaycashShopService" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                  <SOAP-ENV:Body>
                    <ns1:PaymentCancellationResponse/>
                  </SOAP-ENV:Body>
                </SOAP-ENV:Envelope>'

              { xml: body }
            else
              { nothing: true, status: 500 }
            end
          end

          def success_contract_response(item_id, lifetime)
            if contract?
              reg_data = {
                  'orderID' => item_id,
                  'customerNumber' => user_params[:customerNumber],
                  'sms' => user_params[:sms],
                  'serviceNumber' => user_params[:serviceNumber]
              }

              contract_xml = CGI.escape_html(%Q{<?xml version="1.0" encoding="utf-8"?>
                  <contract>
                    <param id="orderID" ref="orderID" label="Номер заказа">#{item_id}</param>
                    <param id="userInfo" ref="userInfo" label="Описание заказа">Оплата заказа #{item_id}</param>
                  </contract>})

              body = %Q{<?xml version="1.0" encoding="UTF-8"?>
              <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:PaycashShopService" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                <SOAP-ENV:Body>
                  <ns1:PaymentContractResponse>
                    <Sum xsi:type="xsd:float">#{user_params[:sum].to_f}</Sum>
                    <PayeeRegData xsi:type="xsd:string">#{dump_reg_data(reg_data)}</PayeeRegData>
                    <Contract xsi:type="xsd:string">#{contract_xml}</Contract>
                    <PaymentDelay xsi:type="xsd:int">#{lifetime}</PaymentDelay>
                  </ns1:PaymentContractResponse>
                </SOAP-ENV:Body>
              </SOAP-ENV:Envelope>}

              { xml: body }
            else
              { nothing: true, status: 500 }
            end
          end

          def failure_response(kind, message = 'An error has happened')
            raise ArgumentError.new('Unknown error kind!') unless FAULT_CODES.include?(kind.to_s)

            body = %Q{<?xml version="1.0" encoding="UTF-8"?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
              <SOAP-ENV:Body>
                <SOAP-ENV:Fault>
                  <faultcode>#{kind}</faultcode>
                  <faultstring>#{message}</faultstring>
                </SOAP-ENV:Fault>
              </SOAP-ENV:Body>
            </SOAP-ENV:Envelope>}

            { xml: body, status: 500 }
          end

          private

          def dump_reg_data(reg_data)
            reg_data = params_to_query(reg_data) if reg_data.is_a?(Hash)
            CGI.escape_html(reg_data.to_s)
          end

          def nori
            @nori ||= Nori.new(
                {
                    strip_namespaces: true,
                    convert_tags_to: lambda { |tag| tag.snakecase.to_sym },
                    advanced_typecasting: true,
                    parser: :nokogiri
                })
          end

          def parse_xml(xml)
            doc = nori.parse(xml)
            body = doc[:envelope].try(:[], :body)
            response = {}

            if body.present?
              @key = [:payment_authorization, :payment_contract, :payment_cancellation].find { |_| body[_].present? }
              response = body[@key] if @key.present?
            end

            response
          end

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
