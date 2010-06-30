module CustomFields
  module Types
    module Date
        
      extend ActiveSupport::Concern
      
      included do
        register_type :date, ::Date
      end
    
      module InstanceMethods
        
        def apply_date_type(klass)
          
          klass.class_eval <<-EOF
            def #{self.safe_alias}
              self.#{self._name}.strftime(I18n.t('date.formats.default')) rescue nil
            end
            
            def #{self.safe_alias}=(value)
              if value.is_a?(String)
                date = ::Date._strptime(value, I18n.t('date.formats.default'))
                value = Date.new(date[:year], date[:mon], date[:mday])
              end
              self.#{self._name} = value
            end
          EOF
          
        end
          
      end
    
    end
  end
end