# encoding: utf-8
module Mongoid #:nodoc:
  module Document
    module InstanceMethods
      def parentize_with_custom_fields(object, association_name)
        parentize_without_custom_fields(object, association_name)
        
        if self.custom_fields?(object, association_name)
          object.send(self.custom_fields_association_name(association_name)).each do |field|
            field.apply(self, association_name)
          end
        end
      end
      
      alias_method_chain :parentize, :custom_fields
      
      def custom_fields_association_name(association_name)
        "#{association_name.singularize}_fields".to_sym
      end
      
      def custom_fields?(object, association_name)
        object.respond_to?(custom_fields_association_name(association_name)) &&
        object.associations[association_name] && 
        object.associations[association_name].options.custom_fields
      end      
    end    
  end
end