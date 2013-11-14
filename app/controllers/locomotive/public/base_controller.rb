module Locomotive
  module Public
    class BaseController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::ActionController::LocaleHelpers
      include Locomotive::ActionController::SectionHelpers
      include Locomotive::ActionController::UrlHelpers
      include Locomotive::ActionController::Timezone

      skip_load_and_authorize_resource

      around_filter :set_timezone

      before_filter :require_site

      protected

      def set_locale
        logger.info "[public/set_locale] TO BE OVERRIDEN"
      end

    end
  end
end