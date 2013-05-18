require 'digest/hmac'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Qiwi
        module Common
          def generate_signature_string
            %w[orderSumAmount orderSumCurrencyPaycash orderSumBankPaycash shopId invoiceId customerNumber].map { |param|
              params[param].to_s
            }.join(';')
          end

          def generate_signature
            Digest::HMAC.hexdigest("data", "hash key", Digest::SHA1)
          end
        end
      end
    end
  end
end
