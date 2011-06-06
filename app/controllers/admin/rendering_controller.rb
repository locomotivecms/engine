module Admin
  class RenderingController < ActionController::Metal

    # Rendering and redirection support
    include ActionController::Redirecting
    include ActionController::Rendering

    # Devise and other helper methods
    include ActionController::Helpers
    include Devise::Controllers::Helpers
    include Rails.application.routes.url_helpers

    # Flash support
    include ActionController::Flash

    # Before filters
    include AbstractController::Callbacks

    # Locomotive Routing and Rendering
    include Locomotive::Routing::SiteDispatcher
    include Locomotive::Render

    before_filter :require_site

    def show
      render_locomotive_page
    end

  end
end
