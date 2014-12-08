module Locomotive
  module Api
    class TokensController < BaseController

      skip_before_filter :require_account, :require_site, :validate_site_membership, :set_current_thread_variables

      def create
        begin
          token = Account.create_api_token(params[:email], params[:password], params[:api_key])
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

      private

      def set_locale
        I18n.locale = Locomotive.config.locales.first
      end

    end
  end
end
