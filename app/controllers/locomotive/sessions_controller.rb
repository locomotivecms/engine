module Locomotive
  class SessionsController < ::Devise::SessionsController

    include Locomotive::Routing::SiteDispatcher

    layout '/locomotive/layouts/not_logged_in'

    before_filter :require_site

    before_filter :set_locale

    helper 'locomotive/base'

    protected

    def after_sign_in_path_for(resource)
      pages_url
    end

    def after_sign_out_path_for(resource)
      request.protocol + request.host_with_port
    end

    def set_locale
      I18n.locale = current_site.accounts.first.locale
    end

  end
end
