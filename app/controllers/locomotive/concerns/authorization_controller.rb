require 'pundit'

module Locomotive
  module Concerns
    module AuthorizationController
      extend ActiveSupport::Concern

      included do
        include ::Pundit
        rescue_from Exception, with: :render_access_denied
      end

      def render_access_denied(exception)
        ::Locomotive.log "[AccessDenied] #{exception.inspect}"

        status = (case exception
        when ::Pundit::NotAuthorizedError         then 401
        when ::Mongoid::Errors::DocumentNotFound  then 404
        else 500
          raise exception
        end)

        if request.xhr?
          render json: { error: exception.message }, status: status, layout: false
        else
          flash[:alert] = exception.message
          redirect_to pages_path
        end
      end

    end
  end
end
