module Locomotive
  class Select2Input < Formtastic::Inputs::SelectInput

    def to_html
      input_wrapping do
        label_html <<
        builder.hidden_field(method, input_html_options.merge({data: select2_options}))
      end
    end

    def select2_options
      opts = input_html_options[:data] || {}
      opts[:url] = options[:url]
      opts[:current_value] = options[:current_value]._label if options[:current_value]
      opts
    end
  end
end