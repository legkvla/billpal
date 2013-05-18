module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Platron
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include Common

          attr_reader :action, :account, :secret

          def initialize(post, options = {})
            [:action, :account, :secret].each do |param|
              instance_variable_set("@#{param}", options.delete(param))
              raise ArgumentError.new("options[:#{param}] can't be empty!") if instance_variable_get("@#{param}").blank?
            end

            super
          end

          def self.recognizes?(params)
            params.has_key?('pg_order_id') && params.has_key?('pg_payment_id') &&
                params.has_key?(ActiveMerchant::Billing::Integrations::Platron.signature_parameter_name)
          end

          def item_id
            params['pg_order_id']
          end

          def security_key
            params[ActiveMerchant::Billing::Integrations::Platron.signature_parameter_name]
          end

          def status
            if paid?
              'paid'
            elsif canceled?
              'canceled'
            elsif refunded?
              'refunded'
            end
          end

          def main_params
            [item_id, status]
          end

          def amount
            BigDecimal.new(gross)
          end

          def gross
            params['pg_amount']
          end

          def refunded?
            acknowledge && params['pg_refund_id'].present?
          end

          def paid?
            acknowledge && !refunded? && params['pg_result'].to_s == '1'
          end

          alias_method :complete?, :paid?

          def canceled?
            acknowledge && !refunded? && params['pg_result'].to_s == '0'
          end

          def acknowledge
            security_key.downcase == generate_signature_string(@action)
          end

          def success_response
            { xml: response_xml(status.present? ? :ok : :error) }
          end

          private

          def response_xml status
            response_params = {
              pg_status: status,
              pg_salt: pg_salt
            }
            response_params[ActiveMerchant::Billing::Integrations::Platron.signature_parameter_name] = generate_signature(@action, response_params)

            body = response_params.map { |key, value| "<#{key}>#{value}</#{key}>" }.join

            %Q{<?xml version="1.0" encoding="utf-8"?><response>#{body}</response>}
          end
        end
      end
    end
  end
end
