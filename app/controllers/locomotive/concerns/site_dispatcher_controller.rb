module Locomotive
  module Concerns
    module SiteDispatcherController

      extend ActiveSupport::Concern

      included do
        if self.respond_to?(:before_filter)
          helper_method :current_site
        end
      end

      protected

      def current_site
        @current_site ||= request.env['locomotive.site']
      end

      def require_site
        return true if current_site

        if Locomotive::Account.count == 0 || Locomotive::Site.count == 0
          redirect_to installation_url
        else
          render_no_site_error
        end

        false # halt chain
      end

      def render_no_site_error
        respond_to do |format|
          format.html do
            render template: '/locomotive/errors/no_site', layout: false, status: :not_found
          end
          format.json do
            render json: { error: 'No site found' }, status: :not_found
          end
        end
      end

    end
  end
end
