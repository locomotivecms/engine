module Locomotive
  module Liquid
    module Tags
      module Editable
        class Text < Base

          protected

          def render_element(context, element)
            content = element.default_content? ? render_default_content(context) : element.content

            if self.editable?(context, element)
              self.render_editable_element(element, content)
            else
              content
            end
          end

          def render_editable_element(element, content)
            tag_name  = 'div'
            css       = 'editable-text'

            unless element.line_break?
              tag_name  = 'span'
              css       += ' editable-single-text'
            end

            %{
              <#{tag_name} class='#{css}' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                #{content}
              </#{tag_name}>
            }
          end

          def document_type
            EditableText
          end

          def editable?(context, element)
            context.registers[:inline_editor] &&
            %(raw html).include?(element.format) &&
            (!element.fixed? || (element.fixed? && !element.from_parent?))
          end

          def default_element_attributes
            super.merge(
              content_from_default: self.render_default_content(nil),
              format:               @options[:format] || 'html',
              rows:                 @options[:rows] || 10,
              line_break:           @options[:line_break].blank? ? true : @options[:line_break]
            )
          end

        end

        ::Liquid::Template.register_tag('editable_text', Text)

        class ShortText < Text
          def initialize(tag_name, markup, tokens, context)
            Rails.logger.warn %(The "editable_<short|long>_text" liquid tags are deprecated. Use "editable_text" instead.)
            super
          end
          def default_element_attributes
            super.merge(format: 'raw', rows: 2, line_break: false)
          end
        end
        ::Liquid::Template.register_tag('editable_short_text', ShortText)

        class LongText < ShortText
          def default_element_attributes
            super.merge(format: 'html', rows: 15, line_break: true)
          end
        end
        ::Liquid::Template.register_tag('editable_long_text', LongText)

      end
    end
  end
end
