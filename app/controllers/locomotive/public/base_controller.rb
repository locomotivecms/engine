module Locomotive
  module Public
    class BaseController < ApplicationController

      include Locomotive::Concerns::SiteDispatcherController
      include Locomotive::ActionController::LocaleHelpers
      include Locomotive::ActionController::UrlHelpers
      include Locomotive::ActionController::Timezone
      include Concerns::AuthorizationController

      around_filter :set_timezone

      before_filter :require_site

      protected

      def set_locale
        logger.info "[public/set_locale] TO BE OVERRIDEN"
      end

    end
  end
end
