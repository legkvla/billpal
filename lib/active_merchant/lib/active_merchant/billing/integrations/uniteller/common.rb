module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Uniteller
        module Common
          def generate_signature_string
            %w[Order_IDP Subtotal_P MeanType EMoneyType Lifetime Customer_IDP Card_IDP IData PT_Code].map { |param|
              Digest::MD5.hexdigest(params[param].to_s)
            }.join('&')
          end

          def generate_signature
            shop_idp_hash = Digest::MD5.hexdigest(shop_idp)
            secret_hash = Digest::MD5.hexdigest(secret)

            Digest::MD5.hexdigest("#{shop_idp_hash}&#{generate_signature_string}&#{secret_hash}").upcase
          end
        end
      end
    end
  end
end
