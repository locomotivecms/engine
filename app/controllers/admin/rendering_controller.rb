module Admin
  class RenderingController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    include Locomotive::Render

    before_filter :require_site

    def show
      render_locomotive_page
    end

  end
end
