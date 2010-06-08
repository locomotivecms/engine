module CustomFields
  module Types        
    module Default
      extend ActiveSupport::Concern
      
      module InstanceMethods
        
        def apply_default_type(klass)
          klass.class_eval <<-EOF
            alias :#{self.safe_alias} :#{self._name}
            alias :#{self.safe_alias}= :#{self._name}=
          EOF
        end
        
      end      
    end
  end
end