module Locomotive
  module Public
    class PagesController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::Render
      include Locomotive::ActionController::LocaleHelpers

      before_filter :require_site

      before_filter :authenticate_locomotive_account!, :only => [:show_toolbar]

      before_filter :validate_site_membership, :only => [:show_toolbar]

      before_filter :set_toolbar_locale, :only => :show_toolbar

      before_filter :set_locale, :only => [:show, :edit]

      def show_toolbar
        render :layout => false
      end

      def show
        render_locomotive_page
      end

      def edit
        @editing = true
        render_locomotive_page
      end

      protected

      def set_toolbar_locale
        ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
        ::Mongoid::Fields::I18n.locale = session[:content_locale] || current_site.default_locale
      end

      def set_locale
        ::Mongoid::Fields::I18n.locale = params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks
      end

    end
  end
end