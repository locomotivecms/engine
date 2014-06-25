module Locomotive
  module Concerns
    module AuthorizationController
      extend ActiveSupport::Concern

      included do
        include Pundit
        rescue_from Pundit::NotAuthorizedError do |exception|
          ::Locomotive.log "[Pundit::AccessDenied] #{exception.inspect}"

          if request.xhr?
            render json: { error: exception.message }
          else
            flash[:alert] = exception.message

            redirect_to pages_path
          end
        end
      end

    end
  end
end
