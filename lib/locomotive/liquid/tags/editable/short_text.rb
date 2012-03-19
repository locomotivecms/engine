module Locomotive
  module Liquid
    module Tags
      module Editable
        class ShortText < Base

          protected

          def render_element(context, element)
            content = element.default_content? ? render_default_content(context) : element.content

            if editable?(context, element)
              %{
                <span class='editable-short-text' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                  #{content}
                </span>
              }
            else
              content
            end
          end

          def document_type
            EditableShortText
          end

          def editable?(context, element)
            context.registers[:inline_editor] && (!element.fixed? || (element.fixed? && !element.from_parent?))
          end

        end

        ::Liquid::Template.register_tag('editable_short_text', ShortText)
      end
    end
  end
end
