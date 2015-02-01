module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Concerns::TokenAuthenticationController
      include Locomotive::Concerns::ExceptionController
      include Locomotive::Concerns::AuthorizationController

      include Locomotive::Concerns::WithinSiteController

      skip_before_filter :verify_authenticity_token

      before_filter :set_locale

      self.responder = Locomotive::ActionController::Responder # custom responder

      respond_to :json, :xml

      private

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
