module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Platron
        autoload :Helper, File.dirname(__FILE__) + '/platron/helper.rb'
        autoload :Notification, File.dirname(__FILE__) + '/platron/notification.rb'
        autoload :Return, File.dirname(__FILE__) + '/platron/return.rb'
        autoload :Common, File.dirname(__FILE__) + '/platron/common.rb'

        mattr_accessor :test_url
        self.test_url = 'https://www.platron.ru/payment.php'

        mattr_accessor :production_url
        self.production_url = 'https://www.platron.ru/payment.php'

        mattr_accessor :signature_parameter_name
        self.signature_parameter_name = 'pg_sig'

        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
            when :production
              self.production_url
            when :test
              self.test_url
            else
              raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.helper(order, account, options = {})
          Helper.new(order, account, options)
        end

        def self.notification(query_string, options = {})
          Notification.new(query_string, options)
        end

        def self.return(query_string, options = {})
          Return.new(query_string, options)
        end
      end
    end
  end
end
