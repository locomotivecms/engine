module Locomotive
  class CodeInput < Formtastic::Inputs::TextInput

    def input_wrapping(&block)
      elements = [template.capture(&block), error_html, toolbar_html, hint_html]

      template.content_tag(:li, elements.join("\n").html_safe, wrapper_html_options)
    end

    def hint_text
      localized_string(method, options[:hint], :hint)
    end

    def to_html
      input_wrapping do
        builder.text_area(method, input_html_options)
      end
    end

    def toolbar_html
      elements = [image_picker_html, copy_from_main_locale_html].compact

      return '' if elements.size == 0

      template.content_tag(:div,
        elements.join('&nbsp;|&nbsp;').html_safe,
        class: 'more error-anchor')
    end

    def image_picker_html
      return nil if options.delete(:picker) == false

      template.link_to(
        template.content_tag(:i, '', class: 'icon-picture') +
        template.t('locomotive.code_editing.image_picker'),
        template.theme_assets_path, id: 'image-picker-link', class: 'picture')
    end

    def copy_from_main_locale_html
      url = options.delete(:main_locale_template_url)

      return nil unless url

      template.link_to(
        template.content_tag(:i, '', class: 'icon-download') +
        template.t('locomotive.code_editing.copy_template'),
        url, id: 'copy-template-link', class: 'copy')
    end

  end
end