module CustomFields
  module Types
    module Boolean
        
      extend ActiveSupport::Concern
      
      included do
        register_type :boolean
      end
    
      module InstanceMethods
        
        def apply_boolean_type(klass)
          
          klass.class_eval <<-EOF
            alias :#{self.safe_alias}= :#{self._name}=
            
            def #{self.safe_alias}
              ::Boolean.set(read_attribute(:#{self._name}))
            end            
          EOF
          
        end
          
      end
    
    end
  end
end