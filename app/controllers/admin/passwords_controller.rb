module Admin
  class PasswordsController < Devise::PasswordsController
    
    include Locomotive::Routing::SiteDispatcher

    layout 'admin/login'
  
    before_filter :require_site
  
  end
end