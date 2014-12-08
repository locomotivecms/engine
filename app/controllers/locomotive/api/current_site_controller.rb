module Locomotive
  module Api
    class CurrentSiteController < Api::BaseController

      before_filter :load_current_site

      def show
        authorize @site
        respond_with(@site)
      end

      def update
        authorize @site
        @site.from_presenter(params[:site]).save
      	respond_with(@site)
      end

      def destroy
        authorize @site
        @site.destroy
        respond_with(@site)
      end

      private

      def load_current_site
        @site = current_site
      end

    end
  end
end
