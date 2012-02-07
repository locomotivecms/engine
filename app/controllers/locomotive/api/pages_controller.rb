module Locomotive
  module Api
    class PagesController < BaseController

      def index
        @pages = current_site.pages.all
        respond_with(@pages)
      end

      def create
        @page = current_site.pages.create(params[:page])
        respond_with @page, :location => main_app.locomotive_api_pages_url
      end

      def update
        @page = current_site.pages.find(params[:id])
        @page.update_attributes(params[:page])
        respond_with @page, :location => main_app.locomotive_api_pages_url
      end

    end

  end
end

