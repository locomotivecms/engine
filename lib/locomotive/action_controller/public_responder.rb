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
            self.controller.send :render_locomotive_page, navigation_location_for_locomotive, {
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

      def navigation_location_for_locomotive
        locale, location = self.extract_locale_and_location

        if locale
          ::I18n.locale = ::Mongoid::Fields::I18n.locale = locale
          location
        else
          navigation_location
        end
      end

      protected

      def extract_locale_and_location
        locales = self.controller.send(:current_site).locales.join('|')

        if navigation_location =~ /\/(#{locales})+\/(.+)/
          [$1, $2]
        else
          nil
        end
      end

    end
  end
end