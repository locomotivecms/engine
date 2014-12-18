module Locomotive
  module Concerns
    module TokenAuthenticationController

      extend ActiveSupport::Concern

      included do

        before_filter :unsafe_token_authentication_params

        acts_as_token_authentication_handler_for Locomotive::Account

        def find_record_from_identifier(entity)
          if Locomotive.config.unsafe_token_authentication
            Locomotive::Account.where(authentication_token: params[:locomotive_account_token]).first
          else
            super
          end
        end

      end

      private

      def unsafe_token_authentication_params
        if Locomotive.config.unsafe_token_authentication
          params[:locomotive_account_token] = params[:auth_token]
        end
      end

    end
  end
end
