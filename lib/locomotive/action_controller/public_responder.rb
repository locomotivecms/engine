module Locomotive
  module ActionController
    class PublicResponder < ::ActionController::Responder

      def navigation_behavior(error)
        if get?
          raise error
        elsif has_errors? && default_action
          # get the content entry from the controller
          entry = self.controller.instance_variable_get :@entry

          if navigation_location =~ %r(^http://)
            # simple redirection for outside urls
            redirect_to navigation_location
          else
            # render the locomotive page
            self.controller.send :render_locomotive_page, navigation_location, {
              entry.content_type.slug.singularize => entry.to_presenter(include_errors: true).as_json
            }
          end
        else
          entry = self.controller.instance_variable_get :@entry

          self.controller.flash['submitted_entry_id'] = entry.try(:_id).try(:to_s)

          # redirect to a locomotive page
          redirect_to navigation_location
        end
      end

    end
  end
end