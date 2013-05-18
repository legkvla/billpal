require 'securerandom'
require 'csv'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PlatronGateway < Gateway
      include ActiveMerchant::Billing::Integrations::Platron::Common

      self.live_url = 'https://www.platron.ru'

      self.supported_countries = %w(RU)

      self.supported_cardtypes = [:visa, :master]
      self.homepage_url = 'http://www.platron.ru'
      self.display_name = 'Platron'
      self.money_format = :cents
      self.default_currency = 'RUB'
      self.ssl_strict = false

      DEFAULT_TRANSACTION_PARAMS = {
          date_type: 'creation_date',
          csv_output: 1,
          format: 'csv_excel',
          metric: 'received_by_merchant_gross',
          show_date_type: 'creation_date',
          status: 0,
          status2: 0,
          sort: 1
      }

      def initialize(options = {})
        requires!(options, :account, :secret)

        @node_id = options.delete(:node_id)
        @node_secret = options.delete(:node_secret)

        super
      end

      def account
        @options[:account]
      end

      def secret
        @options[:secret]
      end

      def node_id
        @node_id
      end

      def node_secret
        @node_secret
      end

      def get_payment_id(order_id)
        get_raw_payment(order_id).try(:[], 'pg_payment_id')
      end

      def void(payment_id)
        refund(payment_id, 0)
      end

      def refund(payment_id, money)
        check_payment_id!(payment_id)

        refund_params = {
            pg_payment_id: payment_id,
            pg_refund_amount: money.to_f,
        }

        refund_response = get_raw_response('revoke.php', refund_params)

        Response.new(!has_error?(refund_response), raw_message(refund_response), refund_response)
      end

      def cancel(payment_id)
        check_payment_id!(payment_id)

        refund_params = { pg_payment_id: payment_id }

        cancel_response = get_raw_response('cancel.php', refund_params)

        Response.new(!has_error?(cancel_response), raw_message(cancel_response), cancel_response)
      end

      def make_mobile_payment(pg_payment_id, pg_payment_system, pg_amount, email, phone, pg_params = {})
        raw_response = make_raw_payment(pg_payment_id, pg_payment_system, pg_amount, pg_params.merge(
            {
                pg_user_email: email,
                pg_user_contact_email: email,
                pg_user_phone: phone
            }
        ))

        Response.new(complete?(raw_response), raw_message(raw_response), raw_response)
      end

      def make_raw_payment(pg_order_id, pg_payment_system, pg_amount, pg_params = {})
        pg_params.symbolize_keys!
        pg_params[:pg_description] ||= pg_order_id
        pg_params[:pg_user_ip] ||= '127.0.0.1'
        payment_params = pg_params.merge(
            {
                pg_order_id: pg_order_id,
                pg_payment_system: pg_payment_system,
                pg_amount: pg_amount.to_f
            })

        get_raw_response('init_payment.php', payment_params)
      end

      def get_raw_payment(payment_id)
        response = get_raw_response('get_status.php', pg_order_id: payment_id)
        response unless response['pg_error_code'].to_s == '340'
      end

      def get_raw_payments(start_time, end_time)
        platron_params = DEFAULT_TRANSACTION_PARAMS.merge(
            {
                begin_date: start_time.strftime('%Y-%m-%d %H:%M'),
                end_date: end_time.strftime('%Y-%m-%d %H:%M'),
                node_id: node_id,
                token: azid_token
            })

        begin
          csv_response = ssl_post('https://www.platron.ru/admin/transactions.php', params_to_query(platron_params))

          rows = CSV.parse(csv_response, quote_char: '"', col_sep: ';', headers: true, return_headers: true).map(&:to_hash)
          rows.shift

          rows.each do |row|
            %w[payment_type amount bill_amount ps_commission pg_commission to_pay].each do |column|
              row[column] = row[column].gsub(',', '.')
            end
          end
        rescue ResponseError => e
          Rails.logger.error "#{e}: #{e.response.code}##{e.response.body}"

          nil
        end
      end

      private

      def check_payment_id!(payment_id)
        raise ArgumentError.new('payment_id should be digit!') unless payment_id.to_s =~ /\A\d+\z/
      end

      def raw_message(response)
        response['pg_error_description'] || response['pg_redirect_url_type'] ||
            response['pg_status']
      end

      def has_error?(response)
        response.blank? || !success_transaction?(response) ||
            response['pg_error_description'].present?
      end

      def complete?(response)
        success_transaction?(response) && response['pg_redirect_url_type'] != 'need data'
      end

      def success_transaction?(response)
        response['pg_status'] == 'ok'
      end

      def azid_token
        Digest::SHA1.hexdigest("from=#{@node_id};to=2;#{@node_secret}")
      end

      def parse(xml)
        doc = MultiXml.parse(xml)
        doc['response']
      end

      def pg_salt
        SecureRandom.hex
      end

      def get_raw_response(action, query_params)
        begin
          query_params[:pg_merchant_id] = account
          query_params[:pg_salt] = pg_salt
          query_params[:pg_sig] = generate_signature(action, query_params)

          raw_response = ssl_post("#{live_url}/#{action}", params_to_query(query_params))

          parse(raw_response)
        rescue ResponseError => e
          Rails.logger.error "#{e}: #{e.response.code}##{e.response.body}"

          nil
        end
      end
    end
  end
end
