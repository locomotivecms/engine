module Locomotive
  module Liquid
    module Tags
      module Editable
        class LongText < ShortText

          protected

          def render_element(context, element)
            content = element.default_content? ? render_default_content(context) : element.content

            if editable?(context, element)
              %{
                <div class='editable-long-text' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                  #{content}
                </div>
              }
            else
              content
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
