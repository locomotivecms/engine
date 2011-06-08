module Admin
  class RenderingController < ActionController::Metal

    # Rendering and redirection support
    include ActionController::Redirecting
    include ActionController::Rendering
    include AbstractController::AssetPaths

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
    before_filter :setup_paths

    helper 'admin/base'

    def show
      render_locomotive_page
    end

    private

    def setup_paths
      append_view_path Rails.root.join('app', 'views')

      self.asset_host = ''
      self.asset_path = Rails.root.join('app', 'public')
      self.assets_dir = 'assets'
      self.javascripts_dir = 'javascripts'
      self.stylesheets_dir = 'stylesheets'

    end

  end
end
