module Locomotive
  module Liquid
    module Tags
      module Editable
        class Select < Base

          protected
          def end_tag
            super
            if @context[:page].present? and
              element = @context[:page].find_editable_element(@context[:current_block].try(:name), @slug)
              element.options = @options[:options]
              element.content ||= render_default_content(@context)
              element.default_content = element.content
              element.update_pages
           end

          end


          def render_element(context, element)
            element.content
          end

          def document_type
            EditableSelect
          end

        end
        ::Liquid::Template.register_tag('editable_select', Select)
      end
    end
  end
end

