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

        message = I18n.t('locomotive.errors.access_denied.message')

        if request.xhr?
          render json: { error: message }, status: 401, layout: false
        else
          flash[:alert] = message
          redirect_to current_site? ? dashboard_path(current_site) : sites_path
        end
      end

      def pundit_user
        current_membership
      end

    end
  end
end
