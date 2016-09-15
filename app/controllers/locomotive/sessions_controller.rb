module Locomotive
  class SessionsController < ::Devise::SessionsController

    include Locomotive::Concerns::SslController
    include Locomotive::Concerns::RedirectToMainHostController
    include Locomotive::Concerns::WithinSiteController

    within_site_only_if_existing true # Note: do not validate the membership

    layout '/locomotive/layouts/account'

    before_filter :set_locale

    helper Locomotive::BaseHelper

    private

    def after_sign_in_path_for(resource)
      current_site? ? dashboard_path(current_site) : sites_path
    end

    def after_sign_out_path_for(resource)
      new_locomotive_account_session_path
    end

    def set_locale
      I18n.locale = current_site? ? current_site.accounts.first.locale : Locomotive.config.default_locale
    end

  end
end
