module Locomotive
  module ActionController
    class PublicResponder < ::ActionController::Responder

      def navigation_behavior(error)
        if get?
          raise error
        elsif has_errors? && default_action
          redirect_to navigation_location
        else
          redirect_to navigation_location
        end
      end

    end
  end
end