# encoding: utf-8
module Mongoid #:nodoc:
  module Associations #:nodoc:
    class EmbedsMany < Proxy
      def build_with_custom_field_settings(attrs = {}, type = nil)
        document = build_without_custom_field_settings(attrs, type)
        
        if @association_name.ends_with?('_custom_fields')
          document.class_eval <<-EOV
            self.associations = {} # prevent associations to be nil
            embedded_in :#{@parent.class.to_s.underscore}, :inverse_of => :#{@association_name}
          EOV
          
          document.send(:set_unique_name!)
          document.send(:set_alias)
        end
        document
      end
      
      alias_method_chain :build, :custom_field_settings
    end
    
  end
end