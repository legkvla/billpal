module SocialNetworks
  module Api
    class Facebook
      URL = 'https://graph.facebook.com/'

      attr_reader :token

      def initialize token
        @token = token
      end

      def method_call path = nil, params = {}
        params.merge! access_token: token, format: :json

        response = connection.get "#{URL}#{path}", params

        MultiJson.load response.env[:response].body, symbolize_keys: true
      end

      def method_call_with_paginate path = nil, params = {}
        data = []

        loop do
          body = method_call path, params

          if body.try(:[], :data).present?
            data += body[:data]

            next_link = body[:paging][:next] rescue nil
            if next_link.present?
              link_params = query_params next_link

              params.merge!(
                  {
                      offset: link_params[:offset],
                      limit: link_params[:limit]
                  })
            else
              break
            end
          else
            break
          end
        end

        data
      end

      def friends
        method_call_with_paginate 'me/friends', fields: 'name,picture'
      end

      def me fields = {}
        method_call :me, fields: 'link,picture,name'
      end

      def self.refresh_token old_token
        url = 'https://graph.facebook.com/oauth/access_token'
        params = {
            client_id: Setting.for(:facebook_id),
            client_secret: Setting.for(:facebook_secret),
            grant_type: :fb_exchange_token,
            fb_exchange_token: old_token
        }
        connection = Faraday.new url: url, ssl: {verify: false}
        response = connection.get url, params
        response.env[:response].body[/\Aaccess_token\=([^\&]+)/, 1]
      end

      private

      def connection
        @connection ||= Faraday.new url: URL, ssl: {verify: false}
      end
    end
  end
end
