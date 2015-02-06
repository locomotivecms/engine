module Locomotive
  module Concerns
    module TokenAuthenticationController

      extend ActiveSupport::Concern

      included do

        before_filter :unsafe_token_authentication_params

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
          params[:locomotive_account_email] = Locomotive::Account.where(authentication_token: params[:auth_token]).first.try(:email)
        end
      end

      public

      module ClassMethods

        def account_required(options = {})
          class_eval do
            acts_as_token_authentication_handler_for Locomotive::Account

            if actions = options[:except]
              skip_before_filter :authenticate_locomotive_account_from_token!, only: :create
            end
          end
        end

      end

    end
  end
end
