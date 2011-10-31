module Locomotive
  class SessionsController < Devise::SessionsController

    include Locomotive::Routing::SiteDispatcher

    layout '/locomotive/layouts/box'

    before_filter :require_site

    helper 'locomotive/base', 'locomotive/box'

    protected

    def after_sign_in_path_for(resource)
      pages_url
    end

    def after_sign_out_path_for(resource)
      request.protocol + request.host_with_port
    end

  end
end
