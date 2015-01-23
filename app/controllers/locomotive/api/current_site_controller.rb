module Locomotive
  module Api
    class CurrentSiteController < Api::BaseController

      account_required & within_site

      before_filter :load_current_site

      def show
        authorize @site
        respond_with @site
      end

      def update
        authorize @site
        @site.from_presenter(params[:site]).save
      	respond_with @site, location: main_app.locomotive_api_current_site_url
      end

      def destroy
        authorize @site
        @site.destroy
        respond_with @site, location: main_app.locomotive_api_my_account_url
      end

      private

      def load_current_site
        @site = current_site
      end

    end
  end
end
