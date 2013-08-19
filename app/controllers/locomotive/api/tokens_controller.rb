module Locomotive
  module Api
    class TokensController < Locomotive::Api::BaseController

      skip_before_filter :require_account, :require_site, :set_current_thread_variables

      def create
        begin
          token = Account.create_api_token(current_site, params[:email], params[:password], params[:api_key])
          respond_with({ token: token }, location: root_url)
        rescue Exception => e
          respond_with({ message: e.message }, status: 401, location: root_url)
        end
      end

      def destroy
        begin
          token = Account.invalidate_api_token(params[:id])
          respond_with({ token: token }, location: root_url)
        rescue Exception => e
          respond_with({ message: e.message }, status: 404, location: root_url)
        end
      end

      protected

      def set_locale
        I18n.locale = Locomotive.config.locales.first
      end

      def self.description
        {
          overall: %{Manage a session token which will be passed to all the other REST calls},
          actions: {
            create: {
              description: %{Generate a session token from either an email and a password OR an api key},
              params: { email: 'String', password: 'String' },
              response: { token: 'String' },
              example: {
                command: %{curl -d 'email=john.doe@acme.org&password=secret' 'http://mysite.com/locomotive/api/tokens.json'},
                response: %({ "token": "dtsjkqs1TJrWiSiJt2gg" })
              }
            },
            destroy: {
              description: %{Make a session token invalid},
              response: { token: 'String' },
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/tokens/dtsjkqs1TJrWiSiJt2gg.json'},
                response: %({ "token": "dtsjkqs1TJrWiSiJt2gg" })
              }
            }
          }
        }
      end

    end
  end
end
