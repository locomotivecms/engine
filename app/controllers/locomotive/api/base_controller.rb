module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::LocaleHelpers

      skip_before_filter :verify_authenticity_token

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
