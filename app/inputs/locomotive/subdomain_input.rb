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
        template.content_tag(:em, "http://") <<
        builder.text_field(method, input_html_options) <<
        template.content_tag(:em, ".#{domain}", :class => 'error-anchor')
      end
    end

  end
end