module Locomotive
  module Liquid
    module Tags
      module Editable
        class Control < Base

          protected

          def default_element_attributes
            if @nodelist.first.is_a?(String)
              content = self.render_default_content(@nodelist.first)

              super.merge(content: content, options: @options[:options])
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

          def render_default_content(node)
            if node
              node.to_s.strip
            else
              nil
            end
          end

        end

        ::Liquid::Template.register_tag('editable_control', Control)
      end
    end
  end
end
