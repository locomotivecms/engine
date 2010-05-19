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
        return unless @association_name.ends_with?('_fields')
        
        target_name = @association_name.gsub(/_fields$/, '').pluralize
        # puts "target_name = #{target_name} / #{@parent.associations.key?(target_name).inspect} / #{@parent.inspect} / #{@parent.associations.inspect}"
        if @parent.associations.key?(target_name)
          @parent.associations[target_name].options.custom_fields
        end
      end
      
    end
    
  end
end