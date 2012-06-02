module Locomotive
  module Api
    class CurrentSiteController < BaseController

      def show
        @site = current_site
        authorize! :show, @site
        respond_with(@site)
      end

    end
  end
end
