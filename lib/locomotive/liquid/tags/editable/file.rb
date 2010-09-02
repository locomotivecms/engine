module Locomotive
  module Liquid
    module Tags
      module Editable
        class File < Base

          protected

          def render_element(context, element)
            element.source? ? element.source.url : element.default_content
          end

          def document_type
            EditableFile
          end

        end

        ::Liquid::Template.register_tag('editable_file', File)
      end
    end
  end
end
