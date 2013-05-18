module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Uniteller
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include Common

          def self.recognizes?(params)
            params.has_key?('Order_ID') && params.has_key?('Status')
          end

          def item_id
            params['Order_ID']
          end

          def security_key
            params[ActiveMerchant::Billing::Integrations::Uniteller.signature_parameter_name]
          end

          def status
            params['Status'].downcase
          end

          def secret
            @options[:secret]
          end

          def main_params
            [item_id, status]
          end

          def paid?
            acknowledge && %w[paid authorized].include?(status)
          end

          alias_method :complete?, :paid?

          def canceled?
            acknowledge && (status == 'canceled')
          end

          def acknowledge
            signature_hash = Digest::MD5.hexdigest %Q{#{item_id}#{status}#{secret}}

            %w[paid authorized canceled].include?(status) &&
                (security_key.upcase == signature_hash.upcase)
          end

          def success_response(*args)
            { nothing: true }
          end
        end
      end
    end
  end
end
