module Locomotive
  class RteInput < Formtastic::Inputs::TextInput

    def to_html
      input_wrapping do
        label_html <<
        builder.text_area(method, input_html_options) <<
        template.content_tag(:span, '', :class => 'error-anchor')
      end
    end

  end
end