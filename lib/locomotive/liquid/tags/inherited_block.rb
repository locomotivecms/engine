module Locomotive
  module Liquid
    module Tags
      class InheritedBlock < ::Liquid::InheritedBlock

        def end_tag
          super

          if self.contains_super?(@nodelist) # then enable all editable_elements (coming from the parent block too)
            @context[:page].enable_editable_elements(@name)
          end
        end

        protected

        def contains_super?(nodelist)
          nodelist.any? do |node|
            if node.is_a?(String) && node =~ /\{\{\s*block.super\s*\}\}/
              true
            elsif node.respond_to?(:nodelist) && !node.is_a?(Locomotive::Liquid::Tags::InheritedBlock)
              contains_super?(node.nodelist)
            end
          end
        end

      end

      ::Liquid::Template.register_tag('block', InheritedBlock)
    end
  end
end