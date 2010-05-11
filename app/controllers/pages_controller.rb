class PagesController < ActionController::Base
  
  include Locomotive::Routing::SiteDispatcher
  
  before_filter :require_site
  
  def show
    logger.debug "fullpath = #{request.fullpath}"
    # @page = current_site.pages.find    
  end
  
end