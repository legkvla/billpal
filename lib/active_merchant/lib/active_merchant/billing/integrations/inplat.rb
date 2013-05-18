module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Inplat
        autoload :Notification, File.dirname(__FILE__) + '/inplat/notification.rb'
        autoload :Common, File.dirname(__FILE__) + '/inplat/common.rb'

        def self.notification(query_string, options = {})
          Notification.new(query_string, options)
        end
      end
    end
  end
end
