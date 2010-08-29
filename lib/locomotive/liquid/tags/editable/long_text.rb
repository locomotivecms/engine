module Locomotive
  module Liquid
    module Tags
      module Editable
        class LongText < ShortText
        end

        ::Liquid::Template.register_tag('editable_long_text', LongText)
      end
    end
  end
end
