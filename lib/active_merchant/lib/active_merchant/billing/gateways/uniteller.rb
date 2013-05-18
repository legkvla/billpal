require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class UnitellerGateway < Gateway
      self.live_url = 'https://wpay.uniteller.ru'

      self.supported_countries = %w(RU)

      self.supported_cardtypes = [:visa, :master]
      self.homepage_url = 'http://uniteller.ru'
      self.display_name = 'Uniteller'
      self.money_format = :cents
      self.default_currency = 'RUB'
      self.ssl_strict = false

      RESPONSE_FORMATS = {
          csv: 1,
          wddx: 2,
          brackets: 3,
          xml: 4,
          soap: 5
      }

      ACTION_RESPONSE_FORMATS = {
          csv: 1,
          wddx: 2,
          xml: 3,
          soap: 4
      }

      def initialize(options = {})
        requires!(options, :account, :secret, :login)
        super
      end

      def refund(bill_number, money)
        check_bill_number! bill_number

        raise ArgumentError.new('Should be greater or equal to 0.01!') if money.to_f < 0.01

        query_params = uniteller_params.merge(
            {
                Billnumber: bill_number,
                Format: ACTION_RESPONSE_FORMATS[:xml],
                Subtotal_P: money.to_f
            })

        refund_response = get_raw_response(:unblock, query_params)

        if has_error? refund_response
          Response.new(false, error_message(refund_response), refund_response)
        else
          refund_response = order(refund_response)
          Response.new(paid_or_authorized?(refund_response['status']), refund_response['status'], refund_response)
        end
      end

      def void(bill_number)
        check_bill_number! bill_number

        query_params = uniteller_params.merge({Billnumber: bill_number, Format: ACTION_RESPONSE_FORMATS[:xml]})

        void_response = get_raw_response(:unblock, query_params)

        if has_error? void_response
          Response.new(false, error_message(void_response), void_response)
        else
          void_hash = order(void_response)
          Response.new(canceled?(void_hash['status']), void_hash['status'], void_hash)
        end
      end

      def get_bill_number(payment_id)
        get_raw_payment(payment_id).try(:[], 'billnumber')
      end

      def get_raw_payment(payment_id)
        query_params = uniteller_params.merge({ShopOrderNumber: payment_id})

        raw_response = get_raw_response(:results, query_params)

        order(raw_response)
      end

      def get_raw_payments(start_date, end_date)
        arguments = {}
        arguments.merge!(to_date_params(start_date, :start))
        arguments.merge!(to_date_params(end_date, :end))

        query_params = uniteller_params(arguments)

        raw_response = get_raw_response(:results, query_params)

        [order(raw_response)].flatten.reject(&:blank?)
      end

      def confirm(bill_number)
        check_bill_number! bill_number

        query_params = uniteller_params.merge({Billnumber: bill_number, Format: ACTION_RESPONSE_FORMATS[:xml]})

        raw_response = get_raw_response(:confirm, query_params)

        if has_error? raw_response
          Response.new(false, error_message(raw_response), raw_response)
        else
          order_hash = order(raw_response)
          Response.new(authorized?(order_hash['status']), order_hash['status'], order_hash)
        end
      end

      def self.parse_status status
        case status.downcase.gsub(/\s+/, '_').to_sym
          when :authorized, :paid
            :paid
          when :waiting
            :pending
          when :canceled, :not_authorized
            :canceled
          else
            :failed
        end
      end

      private

      def authorized?(status)
        status == 'Authorized'
      end

      def canceled?(status)
        status == 'Canceled'
      end

      def paid_or_authorized?(status)
        status == 'Paid' || authorized?(status)
      end

      def error_message(response)
        response.try(:[], 'secondcode')
      end

      def has_error?(response)
        response.blank? || order(response).blank? || response['firstcode'].present? ||
            response['secondcode'].present?
      end

      def check_bill_number!(bill_number)
        raise ArgumentError.new('Not a bill number!') unless bill_number.length == 12
      end

      def order hash
        hash['orders'].try(:[], 'order') if hash.present?
      end

      def uniteller_params(query_options = {})
        arguments = query_options.merge(
            {
              Shop_ID: options[:account],
              Login: options[:login],
              Password: options[:secret],
              Format: RESPONSE_FORMATS[:xml]
            })

        arguments
      end

      def to_date_params(date, prefix)
        result = {}

        %w[day month year hour min].each do |field|
          result["#{prefix.to_s.capitalize}#{field.capitalize}"] = date.send(field)
        end

        result
      end

      def parse(xml)
        doc = MultiXml.parse(nokogiri_parse(xml))
        doc['unitellerresult']
      end

      def nokogiri_parse(xml)
        result = Nokogiri::XML.parse(xml) / 'unitellerresult'
        result.to_xml
      end

      def get_raw_response(method, query_params)
        begin
          raw_response = ssl_post("#{live_url}/#{method}", params_to_query(query_params))
          parse(raw_response)
        rescue ResponseError => e
          Rails.logger.error "#{e}: #{e.response.code}##{e.response.body}"

          nil
        end
      end
    end
  end
end

