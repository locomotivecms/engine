module Locomotive
  module Concerns
    module StoreLocationController

      extend ActiveSupport::Concern

      included do
        helper_method :last_saved_location
      end

      private

      def store_location
        session[:return_to] = request.fullpath if request.get?
      end

      def last_saved_location(default)
        session[:return_to] || default
      end

      def last_saved_location!(default)
        session.delete(:return_to) || default
      end

      def redirect_back_or_default(default)
        redirect_to(last_saved_location!(default))
      end

    end
  end
end
