module Locomotive
  module Api
    class TokensController < Api::BaseController

      def create
        begin
          token = Account.create_api_token(params[:email], params[:password], params[:api_key])
          respond_with({ token: token }, location: location_after_request)
        rescue Exception => e
          logger.error "Unable to create a token, reason: #{e.message}"
          respond_with({ message: e.message }, status: 401, location: location_after_request)
        end
      end

      def destroy
        begin
          token = Account.invalidate_api_token(params[:id])
          respond_with({ token: token }, location: location_after_request)
        rescue Exception => e
          respond_with({ message: e.message }, status: 404, location: location_after_request)
        end
      end

      private

      def set_locale
        I18n.locale = Locomotive.config.locales.first
      end

      def location_after_request
        main_app.locomotive_api_my_account_url(format: :json)
      end

    end
  end
end
