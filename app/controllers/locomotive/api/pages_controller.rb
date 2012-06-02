module Locomotive
  module Api
    class PagesController < BaseController

      load_and_authorize_resource :class => Locomotive::Page

      def index
        @pages = current_site.pages.order_by([[:depth, :asc], [:position, :asc]])
        respond_with(@pages)
      end

      def show
        @page = current_site.pages.find(params[:id])
        respond_with(@page)
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

      def destroy
        @page = current_site.pages.find(params[:id])
        @page.destroy
        respond_with @page
      end

    end

  end
end

