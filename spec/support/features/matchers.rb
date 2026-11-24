module Features
  module Matchers

    class HaveNoJavascriptError

      IGNORED = [
        # placeholder.com wants a specific user-agent and answers capybara's image requests with a 403
        'via.placeholder.com',
        # shortcut: the jQuery bundled by jquery-rails (`require jquery`) registers an IE 9-11 only unload
        # handler inside iframes, which Chrome reports. Harmless; goes away with the jQuery 3 migration.
        'Permissions policy violation: unload is not allowed'
      ].freeze

      # browser console errors since the last call (reading the log empties it)
      def self.errors(page)
        page.driver.browser.logs.get(:browser).select do |entry|
          entry.level == 'SEVERE' && IGNORED.none? { |ignored| entry.message.include?(ignored) }
        end
      end

      def matches?(page)
        @js_errors = self.class.errors(page)
        @js_errors.blank?
      end

      def failure_message
        "page expected to have zero javascript error, got: #{@js_errors}"
      end

      def failure_message_when_negated
        "page expected to have javascript errors but got none"
      end

      def description
        "have zero javascript error"
      end

    end

    def have_no_javascript_error
      HaveNoJavascriptError.new
    end

    def self.included base
      if base.respond_to? :register_matcher
        instance_methods.each do |name|
          base.register_matcher name, name
        end
      end
    end

  end
end
