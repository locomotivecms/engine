module Locomotive
  class SmallCodeInput < Formtastic::Inputs::TextInput

    def wrapper_html_options
      super.tap do |opts|
        opts[:class] += ' code small'
      end
    end

    def input_wrapping(&block)
      template.content_tag(:li,
        [template.capture(&block), error_html, error_anchor, hint_html].join("\n").html_safe,
        wrapper_html_options
      )
    end

    def error_anchor
      template.content_tag(:span, '', :class => 'error-anchor')
    end

  end
end