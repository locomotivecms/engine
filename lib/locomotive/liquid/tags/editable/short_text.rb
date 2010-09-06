module Locomotive
  module Liquid
    module Tags
      module Editable
        class ShortText < Base

          protected

          def render_element(context, element)
            if context.registers[:inline_editor]
              %{
                <span class='editable-short-text' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                  #{element.content}
                </span>
              }
            else
              element.content
            end
          end

          def document_type
            EditableShortText
          end

        end

        ::Liquid::Template.register_tag('editable_short_text', ShortText)
      end
    end
  end
end
