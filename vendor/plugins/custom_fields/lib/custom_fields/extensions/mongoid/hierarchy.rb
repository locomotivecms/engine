# encoding: utf-8
module Mongoid #:nodoc
  module Hierarchy #:nodoc
    module InstanceMethods
      
      def parentize_with_custom_fields(object, association_name)
        if association_name.to_s.ends_with?('_custom_fields')
          self.singleton_class.associations = {}
          self.singleton_class.embedded_in object.class.to_s.underscore.to_sym, :inverse_of => association_name
        end
            
        parentize_without_custom_fields(object, association_name)
        
        if self.embedded? && self.instance_variable_get(:"@association_name").nil?
          self.instance_variable_set(:"@association_name", association_name) # weird bug with proxy class
        end
        
        if association_name.to_s.ends_with?('_custom_fields')
          self.send(:set_unique_name!)
          self.send(:set_alias)
        end
      end
      
      alias_method_chain :parentize, :custom_fields
      
    end
  end
end