module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Inplat
        module Common
          def parse_reg_data(reg_data)
            Rack::Utils.parse_nested_query(CGI.unescape_html(reg_data.to_s))
          end
        end
      end
    end
  end
end
