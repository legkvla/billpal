module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoney
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :account, 'shopId'
          mapping :amount, 'sum'
          mapping :order, 'orderNumber'
          mapping :customer_id, 'customerNumber'
          mapping :scid, 'scid'
          mapping :bank_id, 'bankId'
          mapping :shop_article_id, 'shopArticleId'

          mapping :payment_aviso_url, 'paymentAvisoURL'
          mapping :check_url, 'checkURL'

          mapping :return_success_url, 'successURL'
          mapping :return_failure_url, 'failURL'

          mapping :return_shop_success_url, 'shopSuccessURL'
          mapping :return_shop_failure_url, 'shopFailURL'

          def initialize(order, account, options = {})
            @_secret = options.delete(:secret)
            @_scid = options.delete(:scid)
            super
            @fields[mappings[:scid]] = @_scid
          end

          def account
            @fields[mappings[:account]]
          end

          def scid
            @fields[mappings[:scid]]
          end

          def params
            @fields
          end

          def secret
            @_secret
          end

          def form_fields
            @fields
          end
        end
      end
    end
  end
end
