# encoding: utf-8
module Mongoid #:nodoc:
  module Associations #:nodoc:
    class Options #:nodoc:
      def custom_fields
        @attributes[:custom_fields] == true
      end
    end
  end
end