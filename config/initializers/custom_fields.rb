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

# encoding: utf-8
module Mongoid #:nodoc:
  module Associations #:nodoc:
    class EmbedsMany < Proxy
      def build_with_custom_field_settings(attrs = {}, type = nil)
        document = build_without_custom_field_settings(attrs, type)
        if self.target_custom_field_association?
          document.send(:set_unique_name!)
          document.send(:set_alias)
        end
        document
      end
      
      alias_method_chain :build, :custom_field_settings
      
      def target_custom_field_association?
        target_name = @association_name.gsub(/_fields$/, '').pluralize
        # puts "target_name = #{target_name} / #{@parent.associations.key?(target_name).inspect} / #{@parent.inspect} / #{@parent.associations.inspect}"
        if @parent.associations.key?(target_name)
          @parent.associations[target_name].options.custom_fields
        end
      end
      
    end
    
  end
end

# encoding: utf-8
module Mongoid #:nodoc:
  module Document
    module InstanceMethods
      def parentize_with_custom_fields(object, association_name)
        # puts "...parentize_with_custom_fields...#{self.inspect} - #{object.inspect} - #{association_name}"
        parentize_without_custom_fields(object, association_name)
        
        if self.custom_fields?(object, association_name)
          # puts "custom fields = #{object.asset_fields.inspect}"
          puts "(((((((("
          object.send(self.custom_fields_association_name(association_name)).each do |field|
            # puts "field = #{field.inspect}"
            # self.class.send(:set_field, field.name, { :type => field.field_type })
            field.apply(self, association_name)
          end
          puts "))))))))"
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