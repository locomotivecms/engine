module Locomotive
  module Public
    class PagesController < ApplicationController

      include Locomotive::Concerns::WithinSiteController

      within_site

      include Locomotive::Render

      before_filter :set_locale, only: [:show, :edit]

      helper Locomotive::BaseHelper

      def show
        render_locomotive_page
      end

      protected

      def set_locale
        ::Mongoid::Fields::I18n.locale = request.env['locomotive.locale'] || params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks
      end

    end
  end
end
