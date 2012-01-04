# encoding: utf-8

require 'mongoid'

module Mongoid
  module Document
    def as_json(options = {})
      attrs = super(options)
      attrs["id"] = attrs["_id"]
      attrs
    end
  end
end

# Limit feature for embedded documents

module Mongoid #:nodoc:

  # without callback feature
  module Callbacks

    module ClassMethods

      def without_callback(*args, &block)
        skip_callback(*args)
        yield
        set_callback(*args)
      end

    end

  end
end