module Formtastic
  module Inputs
    module Base
      module Errors
        def error_sentence_html
          error_class = options[:error_class] || builder.default_inline_error_class
          template.content_tag(:div,
            template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.html_safe)), :class => error_class)
        end
      end
    end
  end
end
