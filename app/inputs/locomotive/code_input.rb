module Locomotive
  class CodeInput < Formtastic::Inputs::TextInput

    def input_wrapping(&block)
      template.content_tag(:li,
        [template.capture(&block), error_html, image_picker_html, hint_html].join("\n").html_safe,
        wrapper_html_options
      )
    end

    def hint_text
      localized_string(method, options[:hint], :hint)
    end

    def to_html
      input_wrapping do
        builder.text_area(method, input_html_options)
      end
    end

    def image_picker_html
      return '' if options.delete(:picker) == false
      template.content_tag(:div,
        template.link_to(template.t('locomotive.image_picker.link'), template.theme_assets_path, :id => 'image-picker-link', :class => 'picture'),
        :class => 'more error-anchor')
    end

  end
end