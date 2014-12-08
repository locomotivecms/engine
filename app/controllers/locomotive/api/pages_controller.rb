module Locomotive
  module Api
    class PagesController < BaseController

      before_filter :load_page,  only: [:show, :update, :destroy]
      before_filter :load_pages, only: [:index]

      def index
        authorize Locomotive::Page
        @pages = @pages.order_by(:depth.asc, :position.asc)
        respond_with(@pages)
      end

      def show
        authorize @page
        respond_with(@page)
      end

      def create
        authorize Locomotive::Page
        @page = current_site.pages.build
        @page.from_presenter(params[:page]).save
        respond_with @page, location: main_app.locomotive_api_pages_url
      end

      def update
        authorize @page
        @page.from_presenter(params[:page]).save
        respond_with @page, location: main_app.locomotive_api_pages_url
      end

      def destroy
        authorize @page
        @page.destroy
        respond_with @page
      end

      private

      def load_page
        @page = current_site.pages.find(params[:id])
      end

      def load_pages
        @pages = current_site.pages
      end

    end

  end
end
