module Locomotive
  module RSpec
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

      class IncludeInstanceMethod #:nodoc:

        def initialize(meth)
          @meth = meth
        end

        def matches?(klass)
          @klass = klass
          if RUBY_VERSION =~ /1\.9/
            klass.instance_methods.include?(@meth.to_sym) == true
          else
            klass.instance_methods.include?(@meth.to_s) == true
          end
        end

        def failure_message
          "#{@klass} expected to include the instance method #{@meth}"
        end

        def negative_failure_message
          "#{@klass} expected to not include the instance method #{@meth} but included it.\n"
        end

        def description
          "include instance method #{@meth}"
        end

      end

      def include_instance_method(meth)
        IncludeInstanceMethod.new(meth)
      end

      class IncludeClassMethod #:nodoc:

        def initialize(meth)
          @meth = meth
        end

        def matches?(klass)
          @klass = klass
          if RUBY_VERSION =~ /1\.9/
            klass.methods.include?(@meth.to_sym) == true
          else
            klass.methods.include?(@meth.to_s) == true
          end
        end

        def failure_message
          "#{@klass} expected to include the class method #{@meth}"
        end

        def negative_failure_message
          "#{@klass} expected to not include the class method #{@meth} but included it.\n"
        end

        def description
          "include class method #{@meth}"
        end

      end

      def include_class_method(meth)
        IncludeClassMethod.new(meth)
      end

    end
  end
end
