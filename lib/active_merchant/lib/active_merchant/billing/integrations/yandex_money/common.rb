module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoney
        module Common
          def generate_signature_string
            %w[orderSumAmount orderSumCurrencyPaycash orderSumBankPaycash shopId invoiceId customerNumber].map { |param|
              params[param].to_s
            }.join(';')
          end

          def generate_signature
            Digest::MD5.hexdigest("#{action};#{generate_signature_string};#{secret}").upcase
          end
        end
      end
    end
  end
end
