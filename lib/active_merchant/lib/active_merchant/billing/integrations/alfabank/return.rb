module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Alfabank
        class Return < ActiveMerchant::Billing::Integrations::Return
          def initialize(post, options = {})
            super
            gateway = AlfabankGateway.new options
            @order = gateway.get_order_status(item_id)
          end

          def item_id
            @params['orderId']
          end

          def acknowledge
            @order.success?
          end

          def paid?
            status == :paid
          end

          def authorization?
            status == :authorization
          end

          def canceled?
            status == :canceled
          end

          def status
            AlfabankGateway.order_status(@order.params['order_status']).downcase.to_sym if acknowledge
          end
        end
      end
    end
  end
end
