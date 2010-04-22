class Admin::SessionsController < Devise::SessionsController
    
  include Locomotive::Routing::SiteDispatcher

  layout 'login'
  
  before_filter :require_site
  
end