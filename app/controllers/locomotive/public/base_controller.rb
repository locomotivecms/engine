module Locomotive
  module Public
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::LocaleHelpers
      include Locomotive::ActionController::SectionHelpers
      include Locomotive::ActionController::UrlHelpers

      before_filter :require_site

      protected

      def set_locale
        logger.info "[public/set_locale] TODO"
      end

    end
  end
end