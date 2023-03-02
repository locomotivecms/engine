module Locomotive
  module RSpec
    module Matchers

      class EntityRepresent
        attr_reader :subject, :expected

        def initialize(expected)
          @expected = expected
        end

        def matches?(subject)
          @subject = subject
          exposures.has_key?(expected)
        end

        def failure_message
          "expect that #{subject} would have the key #{expected}"
        end

        def description
          "have the key #{expected}"
        end

        private

        def exposures
          @exposures ||= extract_exposures(@subject.root_exposures)
        end

        def extract_exposures(exposures, hash = {}, prefix = nil)
          exposures.each_with_object(hash) do |exposure, hash|
            key = "#{prefix}#{exposure.attribute}"
            if exposure.is_a?(Grape::Entity::Exposure::NestingExposure)
              hash[key.to_sym] = Hash.new
              extract_exposures(exposure.nested_exposures.to_a, hash, "#{key}__")
            else
              hash[key.to_sym] = exposure
            end
          end
        end
      end

      def represent(attribute)
        EntityRepresent.new(attribute)
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
