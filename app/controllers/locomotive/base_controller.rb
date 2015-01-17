module Locomotive
  class BaseController < ApplicationController

    include Locomotive::Concerns::SiteDispatcherController
    include Locomotive::Concerns::UrlHelpersController
    include Locomotive::ActionController::LocaleHelpers
    include Locomotive::ActionController::Ssl
    include Locomotive::ActionController::Timezone
    include Locomotive::Concerns::ExceptionController
    include Locomotive::Concerns::MembershipController
    include Locomotive::Concerns::AuthorizationController
    include Locomotive::Concerns::StoreLocationController

    layout '/locomotive/layouts/application'

    before_filter :require_ssl

    before_filter :require_account

    before_filter :require_site

    before_filter :set_back_office_locale

    before_filter :set_current_content_locale

    before_filter :validate_site_membership

    around_filter :set_timezone

    helper_method :sections

    helper  Locomotive::BaseHelper,
            Locomotive::Shared::AccountsHelper,
            Locomotive::Shared::SitesHelper,
            Locomotive::ContentTypesHelper

    self.responder = Locomotive::ActionController::Responder # custom responder

    respond_to :html

    protected

    def require_account
      authenticate_locomotive_account!
    end

  end
end
