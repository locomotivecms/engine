module Locomotive
  class PasswordsController < ::Devise::PasswordsController

    include Locomotive::Routing::SiteDispatcher

    layout '/locomotive/layouts/not_logged_in'

    before_filter :require_site

    helper 'locomotive/base'

  end
end
