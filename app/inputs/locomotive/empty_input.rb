module Locomotive
  class EmptyInput
    include Formtastic::Inputs::Base

    def to_html
      input_wrapping do
        label_html
        # render nothing
      end
    end

    def association_primary_key
      begin
        super
      rescue Exception => e
        # does not work correctly with embedded collections
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