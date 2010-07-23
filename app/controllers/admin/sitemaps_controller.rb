module Admin
  class SitemapsController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    before_filter :require_site

    respond_to :xml

    def show
      @pages = current_site.pages.published
      @host = request.host
    end

  end
end
