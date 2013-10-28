module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::Timezone
      include Locomotive::ActionController::LocaleHelpers

      skip_before_filter :verify_authenticity_token

      around_filter :set_timezone

      before_filter :require_account

      before_filter :require_site

      before_filter :set_locale

      before_filter :set_current_thread_variables

      rescue_from Exception, with: :render_access_denied

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
        authenticate_locomotive_account!
      end

      def set_locale
        ::Mongoid::Fields::I18n.locale = params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks
      end

      def render_access_denied(exception)
        status = (case exception
        when ::CanCan::AccessDenied               then 401
        when ::Mongoid::Errors::DocumentNotFound  then 404
        else 500
        end)
        render json: { error: exception.message }, status: status, layout: false
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
