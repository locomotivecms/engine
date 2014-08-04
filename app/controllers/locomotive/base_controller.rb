module Locomotive
  class BaseController < ApplicationController

    include Locomotive::Routing::SiteDispatcher
    include Locomotive::ActionController::LocaleHelpers
    include Locomotive::ActionController::SectionHelpers
    include Locomotive::ActionController::UrlHelpers
    include Locomotive::ActionController::Ssl
    include Locomotive::ActionController::Timezone
    include Locomotive::Concerns::AuthorizationController

    layout '/locomotive/layouts/application'

    before_filter :require_ssl

    before_filter :require_account

    before_filter :require_site

    before_filter :set_back_office_locale

    before_filter :set_current_content_locale

    before_filter :validate_site_membership

    around_filter :set_timezone

    before_filter :set_current_thread_variables

    helper_method :sections, :current_ability

    helper Locomotive::BaseHelper, Locomotive::ContentTypesHelper

    self.responder = Locomotive::ActionController::Responder # custom responder

    respond_to :html

    protected

    def set_current_thread_variables
      Thread.current[:account]  = current_locomotive_account
      Thread.current[:site]     = current_site
    end

    def require_account
      authenticate_locomotive_account!
    end

  end
end
