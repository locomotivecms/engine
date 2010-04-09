module Spec
  module Rails
    module Matchers
      class BeValid  #:nodoc:

        def matches?(model)
          @model = model
          @model.errors.clear
          @model.errors.empty? && @model.valid?
        end

        def failure_message
          "#{@model.class} expected to be valid but had errors:\n  #{@model.errors.full_messages.join("\n  ")}"
        end

        def negative_failure_message
            "#{@model.class} expected to be invalid but was valid.\n" 
          end

        def description
          "be valid"
        end

      end

      def be_valid
        BeValid.new
      end
    end
  end
end