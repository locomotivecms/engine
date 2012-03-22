module Locomotive
  module Liquid
    module Tags
      module Editable
        class Control < Base

          protected

          def default_element_attributes
            if @nodelist.first.is_a?(String)
              super.merge(:content => @nodelist.first.try(:to_s), :options => @options[:options])
            else
              super
            end
          end

          def render_element(context, element)
            element.content
          end

          def document_type
            EditableControl
          end

        end

        ::Liquid::Template.register_tag('editable_control', Control)
      end
    end
  end
end
