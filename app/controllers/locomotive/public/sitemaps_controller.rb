module Locomotive
  module Public
    class SitemapsController < Public::BaseController

      before_filter :set_locale

      respond_to :xml

      include Locomotive::Render

      def show
        if page = current_site.pages.where(fullpath: 'sitemap').first
          render_locomotive_page('sitemap')
        else
          @pages = current_site.pages.published.order_by(:depth.asc, :position.asc)
          respond_with @pages
        end
      end

      protected

      def set_locale
        ::Mongoid::Fields::I18n.locale = request.env['locomotive.locale'] || params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale
      end

    end
  end
end
