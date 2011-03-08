module Admin
  class SitemapsController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    before_filter :require_site

    respond_to :xml

    helper 'admin/pages'

    def show
      @pages = current_site.pages.published
    end

  end
end
