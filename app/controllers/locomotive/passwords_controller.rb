module Locomotive
  class PasswordsController < Devise::PasswordsController

    include Locomotive::Routing::SiteDispatcher

    layout '/locomotive/layouts/box'

    before_filter :require_site

    helper 'locomotive/base', 'locomotive/box'

  end
end
