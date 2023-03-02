module Features
  module Matchers

    class HaveNoJavascriptError

      def matches?(page)
        @js_errors = page.driver.browser.logs.get(:browser).select do |error|
          # placeholder.com is waiting for a specific user-agent so it will raise a 403 error
          # when capybara will try to load the images.
          # we don't mind about those errors.
          !error.message.include?('via.placeholder.com')
        end
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
