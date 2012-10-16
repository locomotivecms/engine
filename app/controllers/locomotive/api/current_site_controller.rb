module Locomotive
  module Api
    class CurrentSiteController < BaseController

      def show
        @site = current_site
        authorize! :show, @site
        respond_with(@site)
      end

      def update
      	@site = current_site
      	authorize! :update, @site
      	@site.update_attributes(params[:site])
      	respond_with(@site)
      end

      def destroy
        @site = current_site
        authorize! :destroy, @site
        @site.destroy
        respond_with(@site)
      end

    end
  end
end
