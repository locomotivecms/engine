module CustomFields
  module Types        
    module Default
      extend ActiveSupport::Concern
            
      included do
        cattr_accessor :field_types
      end      
            
      module InstanceMethods
        
        def apply_default_type(klass)
          klass.class_eval <<-EOF
            alias :#{self.safe_alias} :#{self._name}
            alias :#{self.safe_alias}= :#{self._name}=
          EOF
        end
        
      end
      
      module ClassMethods

        def register_type(kind, klass = ::String)
          self.field_types ||= {}
          self.field_types[kind.to_sym] = klass unless klass.nil?
          
          self.class_eval <<-EOF
            def #{kind.to_s}?
              self.kind.downcase == '#{kind}' rescue false
            end
          EOF
        end
        
      end
    end
  end
end