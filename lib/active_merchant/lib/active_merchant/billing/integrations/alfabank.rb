module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Alfabank
        autoload :Return, File.dirname(__FILE__) + '/alfabank/return.rb'

        def self.return(query_string, options = {})
          Return.new(query_string, options)
        end
      end
    end
  end
end
