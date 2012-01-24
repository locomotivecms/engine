module Locomotive
  module Api
    class PagesController < BaseController

      def index
        @pages = current_site.pages.all
        respond_with(@pages)
      end

      def create
        @page = current_site.pages.create(params[:page])
        respond_with @page, :location => edit_locomotive_api_page_url(@page._id)
      end

      def update
        @page = current_site.pages.find(params[:id])
        @page.update_attributes(params[:page])
        respond_with @page, :location => edit_locomotive_api_page_url(@page._id)
      end

    end

  end
end

