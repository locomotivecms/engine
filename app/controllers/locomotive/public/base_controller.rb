module Locomotive
  module Public
    class BaseController < ApplicationController

      include Locomotive::Concerns::WithinSiteController

      within_site_but_as_guest

      protected

      def set_locale
        logger.info "[public/set_locale] TO BE OVERRIDEN"
      end

    end
  end
end
