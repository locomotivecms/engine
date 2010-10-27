module Admin
  class PasswordsController < Devise::PasswordsController

    include Locomotive::Routing::SiteDispatcher

    layout '/admin/layouts/box'

    before_filter :require_site

    helper 'admin/base', 'admin/box'

  end
end
