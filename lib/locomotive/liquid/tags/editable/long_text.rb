module Locomotive
  module Liquid
    module Tags
      module Editable
        class LongText < ShortText

          protected

          def render_element(context, element)
            if context.registers[:inline_editor]
              %{
                <div class='editable-long-text' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                  #{element.content}
                </div>
              }
            else
              element.content
            end
          end

          def document_type
            EditableLongText
          end

        end

        ::Liquid::Template.register_tag('editable_long_text', LongText)
      end
    end
  end
end
