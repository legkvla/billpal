module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Uniteller
        class Return < ActiveMerchant::Billing::Integrations::Return
          def initialize(post, options = {})
            super
            gateway = UnitellerGateway.new options
            @payment = gateway.get_raw_payment(item_id)
          end

          def item_id
            @params['Order_ID']
          end

          def acknowledge
            @payment.present?
          end

          def paid?
            status == :paid
          end

          def fail?
            [:canceled, :failed].include?(status)
          end

          def pending?
            status == :pending
          end

          def status
            UnitellerGateway.parse_status(@payment['status']) if acknowledge
          end
        end
      end
    end
  end
end
