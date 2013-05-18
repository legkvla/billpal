module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Platron
        class Return < ActiveMerchant::Billing::Integrations::Return
          include Common

          attr_reader :action

          def initialize(post, options = {})
            @action = options.delete(:action)
            raise ArgumentError.new("options[:action] can't be empty!") if @action.blank?

            super
          end

          def item_id
            @params['pg_order_id']
          end

          def payment_id
            @params['pg_payment_id']
          end

          def account
            @options['account']
          end

          def secret
            @options['secret']
          end

          def security_key
            params[ActiveMerchant::Billing::Integrations::Platron.signature_parameter_name]
          end

          def acknowledge
            security_key.upcase == generate_signature(action, pg_params).upcase
          end

          def paid?
            acknowledge && @params['pg_auth_code'].present?
          end

          def fail?
            acknowledge && @params['pg_auth_code'].blank?
          end

          private

          def pg_params
            pg_hash = Hash[params.select { |key, _| key =~ /\Apg\_/ }]
            pg_hash.delete 'pg_sig'
            pg_hash
          end
        end
      end
    end
  end
end
