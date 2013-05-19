module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class JustGateway < Gateway
      self.supported_countries = %w(RU)

      self.homepage_url = 'https://justgateway.com'
      self.display_name = 'just gateway'
      self.money_format = :dollars
      self.default_currency = 'RUB'

      CURRENCY_CODES = %w[mwr mwd mwe]
      PAYMENT_TYPES = %w[phone phone.intl ym wm qiwi visa mc]

      def initialize(options = {})
        requires!(options, :login, :secret)

        #TODO
        #if ActiveMerchant::Billing::Base.integration_mode == :production
        #  self.live_url = 'https://justgateway.com'
        #elsif ActiveMerchant::Billing::Base.integration_mode == :test
        self.live_url = 'https://test.justgateway.com'
        #end

        super
      end

      def get_balance
        commit(:AccountBalanceGet)
      end

      def get_payment_final_amount(amount, type)
        commit(:PaymentFinalAmountGet, {
            amount: amount,
            destination_type_code: type
        })
      end

      def make_payment(amount, type, data)
        commit(:PaymentMake, {
            amount: amount,
            destination_type_code: type,
            destination_data: data
        })
      end

      def get_status(id)
        result = commit(:PaymentStatusGet, transaction_id: id)

        if result.success?
          message = result.params['status']['message']
          Response.new(message != 'failed', message, result.params)
        else
          result
        end
      end

      private

      def successful?(response)
        response.present? && response['error'].nil?
      end

      def message_from(response)
        response['error']['data']['message'] unless successful?(response)
      end

      def commit(method, params = {})
        params[:user_id] = @options[:login]

        request = {
            id: Random.rand(1_000_000),
            jsonrpc: '2.0',
            params: params.merge(signature: sign_params(params))
        }

        response = MultiJson.load ssl_post("#{self.live_url}/api/rest/v1/#{method}", Oj.dump(request, mode: :compat))
        if response['result'].present? && response['result'].is_a?(Hash)
          result = response['result']
        else
          result = response
        end

        Response.new(successful?(response), message_from(response), result)
      end

      def ssl_post url, params
        Faraday.post(url, params).body
      end

      def sign_params(params)
        sorted_params = params.map { |k, v| "#{k}=#{v}" }.sort + [@options[:secret]]
        Digest::MD5.hexdigest(sorted_params.join(';'))
      end
    end
  end
end
