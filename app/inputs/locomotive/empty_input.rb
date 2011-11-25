module Locomotive
  class EmptyInput # < Formtastic::Inputs::HiddenInput
    include Formtastic::Inputs::Base

    def to_html
      input_wrapping do
        label_html
        # render nothing
      end
    end

    def error_html
      ""
    end

    def errors?
      false
    end

    # def hint_html
    #   ""
    # end
    #
    # def hint?
    #   false
    # end

  end
end