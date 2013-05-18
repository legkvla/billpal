module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class InplatGateway < Gateway
      include ActiveMerchant::Billing::Integrations::Inplat::Common

      self.supported_countries = %w(RU)

      self.homepage_url = 'http://www.inplat.ru'
      self.display_name = 'InPlat'
      self.money_format = :cents
      self.default_currency = 'RUB'

      RESPONSE_STATUSES_HASH = {
          '0' => 'Unknown error',
          '1' => 'Success',
          '2' => 'Service temporarily unavailable, try to pay later',
          '3' => 'Invalid request',
          '10' => 'Subscriber available',
          '12' => 'Write-off from the main account is not possible. Your prepaid account not enough money to make the payment. Not enough money for payment',
          '13' => 'Limit exceeded for subscriber',
          '14' => 'Transaction canceled due to start a new transaction',
          '16' => 'Subscriber has not confirmed the transaction',
          '21' => 'Timed backup product',
          '23' => 'Timed for confirmation by the client',
          '101' => 'Exceeds the maximum limit of a one-time payment',
          '102' => 'Exceeded the maximum amount of payments for the period',
          '103' => 'Exceeded the maximum number of payments for the period',
          '105' => 'As a result of the payment account balance falls below the minimum',
          '108' => 'Invalid request parameters',
          '109' => 'Unknown error cancellation of the account',
          '110' => 'Stores returned an invalid contract',
          '112' => 'Time of payment of the order has expired',
          '116' => 'timed response from store',
          '117' => 'Network Error',
          '119' => 'Error on the side of the enterprise',
          '201' => 'Operations denied',
          '205' => 'In circuit without authentication is not allowed to receive this type of card'
      }

      def initialize(options = {})
        requires!(options, :ssl_cert_key_file, :ssl_cert_file)

        if ActiveMerchant::Billing::Base.integration_mode == :production
          self.live_url = 'https://merchant.inplat.ru'
        elsif ActiveMerchant::Billing::Base.integration_mode == :test
          self.live_url = 'https://merchant-demo.inplat.ru'
        end

        super
      end

      def make_payment(phone, abbreviature, account, amount, service_number)
        response = soap_client.call(:init_payment, message: {
            'Phone' => phone,
            'SMS' => "#{abbreviature} #{account} #{amount.to_f}",
            'ServiceNum' => service_number
        })
        init_payment_response = response.body[:init_payment_response]

        error_message = error_from_xml(init_payment_response[:payment_result_str])
        payment_id = init_payment_response[:payment_id]
        payment_result = init_payment_response[:payment_result]

        if payment_id != '0' && payment_result == '1' && error_message.blank?
          Response.new(true, RESPONSE_STATUSES_HASH[payment_result.to_s], init_payment_response)
        else
          init_payment_response.delete(:payment_id)
          Response.new(false, error_message, init_payment_response)
        end
      rescue Savon::SOAPFault => e
        message = error_from_xml(e.to_hash[:fault][:detail])

        Response.new(false, message, e.to_hash)
      end

      def get_raw_payment(payment_id)
        raise ArgumentError.new('payment_id is not digit!') unless payment_id.to_s =~ /\A\d+\z/

        response = soap_client.call(:get_payment, message: {'PaymentID' => payment_id.to_s})
        get_payment_response = response.body[:get_payment_response]

        error_message = error_from_xml(get_payment_response[:payment_result_str])
        payment_id = get_payment_response[:payment_id]
        payment_result = get_payment_response[:payment_result]

        if payment_id != '0' && payment_result == '1' && error_message.blank?
          reg_data = parse_reg_data(get_payment_response[:payee_reg_data].to_s)

          Response.new(true, payment_id, get_payment_response.merge(reg_data))
        else
          get_payment_response.delete(:payment_id)
          Response.new(false, error_message, get_payment_response)
        end
      rescue Savon::SOAPFault => e
        message = error_from_xml(e.to_hash[:fault][:detail])

        Response.new(false, message, e.to_hash)
      end

      private

      def error_from_xml xml
        doc = Nokogiri::XML(CGI.unescape_html(xml.to_s))
        description = (doc / '#errorDescr')

        if description.present?
          description.first.content.strip
        else
          xml
        end
      end

      def soap_client
        Savon.client(
            {
                wsdl: "#{live_url}/wsdl/out_merchant.wsdl",
                ssl_cert_key_file: @options[:ssl_cert_key_file],
                ssl_cert_file: @options[:ssl_cert_file]
            })
      end
    end
  end
end
