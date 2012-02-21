module Locomotive
  module Api
    class CurrentSiteController < BaseController

      def show
        respond_with(current_site)
      end

    end
  end
end
