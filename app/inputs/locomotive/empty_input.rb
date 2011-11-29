module Locomotive
  class EmptyInput # < Formtastic::Inputs::HiddenInput
    include Formtastic::Inputs::Base

    def to_html
      input_wrapping do
        label_html
        # render nothing
      end
    end

    def wrapper_html_options
      super.tap do |opts|
        opts[:class] += ' no-label' unless render_label?
      end
    end

    def error_html
      ""
    end

    def errors?
      false
    end

  end
end