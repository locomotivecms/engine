module Admin
  class RenderingController < ActionController::Metal

    # Logging Support
    include AbstractController::Logger

    # Rendering and redirection support
    include ActionController::Redirecting
    include ActionController::Rendering

    # Devise and other helper methods
    include ActionController::Helpers
    include Devise::Controllers::Helpers
    include Rails.application.routes.url_helpers

    # Flash and CSRF form support
    include ActionController::Flash
    include ActionController::RequestForgeryProtection

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
