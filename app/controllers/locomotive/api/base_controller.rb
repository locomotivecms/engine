module Locomotive
  module Api
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::LocaleHelpers

      before_filter :require_account

      before_filter :require_site

      # before_filter :validate_site_membership

      skip_before_filter :verify_authenticity_token

      self.responder = Locomotive::ActionController::Responder # custom responder

      respond_to :json, :xml

      rescue_from CanCan::AccessDenied do |exception|
        ::Locomotive.log "[CanCan::AccessDenied] #{exception.inspect}"

        if request.xhr?
          render :json => { :error => exception.message }
        else
          flash[:alert] = exception.message

          redirect_to pages_url
        end
      end

      protected

      def current_ability
        @current_ability ||= Ability.new(current_locomotive_account, current_site)
      end

      def require_account
        authenticate_locomotive_account!
      end

    end
  end
end