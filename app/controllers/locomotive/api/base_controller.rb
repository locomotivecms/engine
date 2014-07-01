module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::Timezone
      include Locomotive::ActionController::LocaleHelpers
      include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
      include Concerns::AuthorizationController

      acts_as_token_authentication_handler_for Locomotive::Account

      skip_before_filter :verify_authenticity_token

      around_filter :set_timezone

      before_filter :require_account

      before_filter :require_site

      before_filter :set_locale

      before_filter :set_current_thread_variables

      self.responder = Locomotive::ActionController::Responder # custom responder

      respond_to :json, :xml

      protected

      def set_current_thread_variables
        Thread.current[:account]  = current_locomotive_account
        Thread.current[:site]     = current_site
      end

      def current_ability
        @current_ability ||= Locomotive::Ability.new(current_locomotive_account, current_site)
      end

      def require_account
        authenticate_entity_from_token!
        authenticate_locomotive_account!
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

      def self.cancan_resource_class
        Locomotive::Api::CanCan::ControllerResource
      end

      def self.description
        { overall: 'No documentation', actions: {} }
      end

    end
  end
end
