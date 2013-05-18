require 'securerandom'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Platron
        module Common
          def generate_signature_string(path)
            generate_signature(path, params)
          end

          def generate_signature(path, payment_params)
            payment_params = payment_params.symbolize_keys
            payment_params.delete(:pg_sig)
            payment_params = Hash[payment_params.sort]

            Digest::MD5.hexdigest("#{path};#{payment_params.values.join(';')};#{secret}")
          end

          def pg_salt
            SecureRandom.hex
          end
        end
      end
    end
  end
end
