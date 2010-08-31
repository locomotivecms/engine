module Locomotive
  module Liquid
    module Tags
      module Editable
        class LongText < ShortText

          protected

          def document_type
            EditableLongText
          end

        end

        ::Liquid::Template.register_tag('editable_long_text', LongText)
      end
    end
  end
end
