module CustomFields
  module ProxyClassEnabler
    
    extend ActiveSupport::Concern
    
    included do
      
      cattr_accessor :klass_with_custom_fields
    
      def self.to_klass_with_custom_fields(fields)
        return klass_with_custom_fields unless klass_with_custom_fields.nil?
      
        klass = Class.new(self)
        klass.class_eval <<-EOF
          cattr_accessor :custom_fields
        
          def self.model_name
            @_model_name ||= ActiveModel::Name.new(self.superclass)
          end
          
          def custom_fields
            self.class.custom_fields
          end
        EOF
        
        klass.hereditary = false
        klass.custom_fields = fields
              
        [*fields].each { |field| field.apply(klass) }
      
        klass_with_custom_fields = klass
      end
    
    end
    
  end  
end