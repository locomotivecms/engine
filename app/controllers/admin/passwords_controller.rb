module Admin
  class PasswordsController < Devise::PasswordsController

    include Locomotive::Routing::SiteDispatcher

    layout 'admin/box'

    before_filter :require_site

    helper 'admin/base', 'admin/login'

  end
end
