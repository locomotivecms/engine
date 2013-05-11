module Locomotive
  module Public
    class SitemapsController < Public::BaseController

      respond_to :xml

      def show
        @pages = current_site.pages.published.order_by(:depth.asc, :position.asc)
        respond_with @pages
      end

    end
  end
end