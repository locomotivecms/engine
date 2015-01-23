module Locomotive
  module Concerns
    module AuthorizationController

      extend ActiveSupport::Concern
      include Pundit

      included do
        rescue_from Pundit::NotAuthorizedError, with: :render_access_denied
      end

      private

      def render_access_denied(exception)
        ::Locomotive.log "[AccessDenied] #{exception.inspect}"

        if request.xhr?
          render json: { error: exception.message }, status: 401, layout: false
        else
          flash[:alert] = exception.message
          redirect_to current_site? ? dashboard_path(current_site) : sites_path
        end
      end

      def pundit_user
        current_membership
      end

    end
  end
end
