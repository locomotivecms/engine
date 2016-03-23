module Locomotive
  module Concerns
    module ExceptionController

      extend ActiveSupport::Concern

      included do
        rescue_from Exception, with: :render_exception
      end

      private

      def render_exception(exception)
        ::Locomotive.log "[ApplicationError] #{exception.inspect}"

        status = (case exception
        when ::Mongoid::Errors::DocumentNotFound  then 404
        else
          raise exception unless request.xhr?
          500
        end)

        puts "Backtrace:\n\t#{exception.backtrace.join("\n\t")}" if Rails.env.development? || Rails.env.test?

        if request.xhr?
          render json: { error: exception.message }, status: status, layout: false
        else
          flash[:alert] = exception.message
          redirect_to current_site ? dashboard_path(current_site) : sites_path
        end
      end

    end
  end
end
