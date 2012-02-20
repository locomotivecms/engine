module Locomotive
  module Api
    class TokensController < Locomotive::Api::BaseController

      skip_before_filter :require_account

      def create
        begin
          token = Account.create_api_token(current_site, params[:email], params[:password])
          respond_with({ :token => token }, :location => root_url)
        rescue Exception => e
          respond_with({ :message => e.message }, :status => 401, :location => root_url)
        end
      end

      def destroy
        begin
          token = Account.invalidate_api_token(params[:id])
          respond_with({ :token => token }, :location => root_url)
        rescue Exception => e
          respond_with({ :message => e.message }, :status => 404, :location => root_url)
        end
      end

    end
  end
end
