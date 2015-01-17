module Locomotive
  class SessionsController < ::Devise::SessionsController

    include Locomotive::Concerns::SiteDispatcherController

    layout '/locomotive/layouts/not_logged_in'

    before_filter :set_locale

    helper 'locomotive/base'

    private

    def after_sign_in_path_for(resource)
      sites_path
    end

    def after_sign_out_path_for(resource)
      new_locomotive_account_session_path
    end

    def set_locale
      if current_site
        I18n.locale = current_site.accounts.first.locale
      end
    end

  end
end
