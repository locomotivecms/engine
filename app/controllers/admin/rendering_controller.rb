module Admin
  class RenderingController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    include Locomotive::Render

    before_filter :require_site
    before_filter :authenticate_admin!, :only => [:edit]
    before_filter :validate_site_membership, :only => [:edit]

    def show
      render_locomotive_page
    end

    def edit
      @editing = true
      render_locomotive_page
    end

  end
end
