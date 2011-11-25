module Locomotive
  class SubdomainInput < Formtastic::Inputs::TextInput

    def wrapper_html_options
      super.tap do |opts|
        opts[:class] += ' path'
      end
    end

    def to_html
      domain = options.delete(:domain)

      input_wrapping do
        label_html <<
        builder.text_field(method, input_html_options) <<
        template.content_tag(:em, ".#{domain}")
      end
    end

  end
end