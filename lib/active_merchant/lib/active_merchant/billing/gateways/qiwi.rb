module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class QiwiGateway < Gateway
      self.supported_countries = %w(RU)

      self.supported_cardtypes = [:visa, :master]
      self.homepage_url = 'http://www.qiwi.ru'
      self.display_name = 'QIWI'
      self.money_format = :cents
      self.default_currency = 'RUB'
      self.ssl_strict = false
      self.live_url 'https://w.qiwi.com/api/v2/prv'

      def initialize(options = {})
        requires!(options, :account, :secret)

        super
      end

      def account
        @options[:account]
      end

      def secret
        @options[:secret]
      end

      def make_order(order_id, amount_cents, return_url, json_params = {}, options = {})
        check_amount!(amount_cents)

        json_params.merge!(orderNumber: order_id)

        order_response = get_raw_response(
            'register.do',
            options.merge(
                {
                    orderNumber: order_id,
                    returnUrl: return_url,
                    amount: amount_cents,
                    jsonParams: Oj.dump(json_params, mode: :compat)
                }))

        Response.new(!has_error?(order_response), raw_message(order_response) || order_response['orderId'], convert_hash(order_response))
      end

      def make_pre_order(order_id, amount_cents, return_url, json_params = {}, options = {})
        check_amount!(amount_cents)

        json_params.merge!(orderNumber: order_id)

        order_response = get_raw_response(
            'registerPreAuth.do',
            options.merge(
                {
                    orderNumber: order_id,
                    returnUrl: return_url,
                    amount: amount_cents,
                    jsonParams: Oj.dump(json_params, mode: :compat)
                }))

        Response.new(!has_error?(order_response), raw_message(order_response) || order_response['orderId'], convert_hash(order_response))
      end

      def complete_pre_order(order_id, amount_cents, options = {})
        order_response = get_raw_response(
            'deposit.do',
            options.merge(
                {
                    orderId: order_id,
                    amount: amount_cents
                }))

        Response.new(!has_error?(order_response), raw_message(order_response), convert_hash(order_response))
      end

      def void(order_id, options = {})
        void_response = get_raw_response(
            'reverse.do',
            options.merge({orderId: order_id}))

        Response.new(!has_error?(void_response), raw_message(void_response), convert_hash(void_response))
      end

      def refund(order_id, amount_cents, options = {})
        check_amount!(amount_cents)

        refund_response = get_raw_response(
            'refund.do',
            options.merge({orderId: order_id, amount: amount_cents}))

        Response.new(!has_error?(refund_response), raw_message(refund_response), convert_hash(refund_response))
      end

      def get_order_status(order_id, options = {})
        status_response = get_raw_response(
            'getOrderStatusExtended.do',
            options.merge({orderId: order_id}))

        Response.new(!has_error?(status_response), raw_message(status_response) || parse_status(status_response), convert_hash(status_response))
      end

      def get_order_status_by_number(order_number, options = {})
        status_response = get_raw_response(
            'getOrderStatusExtended.do',
            options.merge({orderNumber: order_number}))

        Response.new(!has_error?(status_response), raw_message(status_response) || parse_status(status_response), convert_hash(status_response))
      end

      def self.order_status(status)
        case status.to_i
          when 0
            'pending'
          when 1, 5
            'authorization'
          when 2
            'paid'
          when 4
            'refund'
          when 6, 3
            'canceled'
        end
      end

      private

      def authorization_string
        Base64.encode64("#{account}:#{secret}")
      end

      def parse_status(response)
        ORDER_STATUSES_HASH[response['orderStatus'].to_s]
      end

      def check_amount!(amount_cents)
        raise ArgumentError.new('amount_cents should be digital!') unless amount_cents.to_s =~ /\A\d+\z/
      end

      def has_error?(response)
        response.blank? || !response['errorCode'].to_i.zero?
      end

      def raw_message(response)
        response['errorMessage']
      end

      def convert_hash(hash)
        Hash[hash.map { |key, value| [key.snakecase, value] }]
      end

      def get_raw_response(action, query_params)
        begin
          query_params.merge!(
              {
                  userName: account,
                  password: secret
              })

          raw_response = ssl_post("#{live_url}/#{action}", params_to_query(query_params))
          MultiJson.load(raw_response)
        rescue ResponseError => e
          Rails.logger.error "#{e}: #{e.response.code}##{e.response.body}"

          nil
        end
      end
    end
  end
end
