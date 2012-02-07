# encoding: utf-8

require 'mongoid'

module Mongoid#:nodoc:
  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs["id"] = attrs["_id"]
      attrs
    end
  end

  module Fields #:nodoc:
    module Internal #:nodoc:
      class RawArray < Mongoid::Fields::Internal::Array
        def resizable?; false; end
      end
    end

    class RawArray < ::Array; end
  end

  # without callback feature
  module Callbacks #:nodoc:
    module ClassMethods #:nodoc:
      def without_callback(*args, &block)
        skip_callback(*args)
        yield
        set_callback(*args)
      end
    end
  end
end