module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Concerns::SiteDispatcherController
      include Locomotive::ActionController::Timezone
      include Locomotive::ActionController::LocaleHelpers
      include Locomotive::Concerns::TokenAuthenticationController
      include Locomotive::Concerns::ExceptionController
      include Locomotive::Concerns::MembershipController
      include Locomotive::Concerns::AuthorizationController

      skip_before_filter :verify_authenticity_token

      around_filter :set_timezone

      before_filter :require_account

      before_filter :require_site

      before_filter :validate_site_membership

      before_filter :set_locale

      self.responder = Locomotive::ActionController::Responder # custom responder

      respond_to :json, :xml

      private

      def require_account
        authenticate_locomotive_account!
      end

      def require_site
        return true if current_site

        render_no_site_error

        false # halt chain
      end

      def set_locale
        locale = params[:locale] ||
          current_site.try(:default_locale) ||
          current_locomotive_account.try(:locale) ||
          Locomotive.config.default_locale

        ::Mongoid::Fields::I18n.locale = locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks if current_site
      end

    end
  end
end
