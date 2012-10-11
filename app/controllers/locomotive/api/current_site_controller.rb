module Locomotive
  module Api
    class CurrentSiteController < BaseController

      def show
        @site = current_site
        authorize! :show, @site if @site
        respond_with(@site)
      end

      def update
      	@site = current_site
      	authorize! :update, @site if @site
      	@site.update_attributes(params[:site])
      	respond_with(@site)
      end

    end
  end
end
