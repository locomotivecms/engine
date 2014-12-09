module Locomotive
  module ActionController
    class PublicResponder < ::ActionController::Responder

      def navigation_behavior(error)
        if get?
          raise error
        elsif has_errors? && default_action
          navigation_error_behavior
        else
          navigation_success_behavior
        end
      end

      def api_location
        success_location
      end

      def navigation_error_behavior
        if error_location =~ %r(^http://)
          # simple redirection for outside urls
          redirect_to error_location
        else
          path = page_path ? page_path : extract_locale_and_path(error_location)

          # render the locomotive page
          assigns = {}

          if content_entry
            slug  = content_entry.content_type.slug.singularize
            entry = content_entry.to_presenter(include_errors: true).as_json
            assigns[slug] = entry
          end

          self.controller.send :render_locomotive_page, path, assigns
        end
      end

      def navigation_success_behavior
        # store in session the newly created content entry
        self.controller.flash['submitted_entry_id'] = self.content_entry.try(:_id).try(:to_s)

        # redirect to a locomotive page
        redirect_to success_location
      end

      def error_location
        callback_url(:error) || (page_path ? request.path : '/')
      end

      def success_location
        callback_url(:success) || (page_path ? request.path : '/')
      end

      # get the content entry from the controller
      def content_entry
        self.controller.instance_variable_get :@entry
      end

      def page_path
        self.controller.params[:path]
      end

      def callback_url(state)
        self.controller.params[:"#{state}_callback"]
      end

      protected

      def extract_locale_and_path(path)
        locales = self.controller.send(:current_site).locales.join('|')

        if path =~ /\/(#{locales})+\/(.+)/
          ::I18n.locale = ::Mongoid::Fields::I18n.locale = $1
          $2
        else
          path
        end
      end

    end
  end
end