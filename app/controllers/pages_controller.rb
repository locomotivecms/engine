class PagesController < ActionController::Base
  
  include Locomotive::Routing::SiteDispatcher
  
  before_filter :require_site
  
  def show; end
  
end