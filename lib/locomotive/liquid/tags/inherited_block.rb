module Locomotive
  module Liquid
    module Tags
      class InheritedBlock < ::Liquid::InheritedBlock

        def end_tag
          super
          
          if !self.contains_super?(@nodelist) # then disable all editable_elements coming from the parent block too and not used
            @context[:page].disable_parent_editable_elements(@name) unless @context[:page].nil?
          end
        end

        protected

        def contains_super?(nodelist)
          nodelist.any? do |node|
            if node.is_a?(::Liquid::Variable) && node.name == 'block.super'
              true
            elsif node.respond_to?(:nodelist) && !node.nodelist.nil? && !node.is_a?(Locomotive::Liquid::Tags::InheritedBlock) 
              contains_super?(node.nodelist)
            end
          end
        end

      end

      ::Liquid::Template.register_tag('block', InheritedBlock)
    end
  end
end