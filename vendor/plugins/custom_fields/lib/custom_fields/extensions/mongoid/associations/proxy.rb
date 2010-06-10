# encoding: utf-8
module Mongoid #:nodoc
  module Associations #:nodoc
    class Proxy #:nodoc
      
      def custom_fields_association_name(association_name)
        "#{association_name.to_s.singularize}_custom_fields".to_sym
      end
      
      def custom_fields?(object, association_name)
        object.respond_to?(custom_fields_association_name(association_name))
      end
      
      def klass
        @klass
      end
      
    end
  end
end