module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::LocaleHelpers

      skip_before_filter :verify_authenticity_token

      before_filter :require_account

      before_filter :require_site

      before_filter :set_locale

      # before_filter :validate_site_membership

      self.responder = Locomotive::ActionController::Responder # custom responder

      respond_to :json, :xml

      protected

      def current_ability
        @current_ability ||= Ability.new(current_locomotive_account, current_site)
      end

      def require_account
        authenticate_locomotive_account!
      end

      def set_locale
        ::Mongoid::Fields::I18n.locale = params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks
      end

    end
  end
end
