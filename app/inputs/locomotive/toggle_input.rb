module Locomotive
  class ToggleInput < Formtastic::Inputs::BooleanInput

    # def label_text_with_embedded_checkbox
    #   label_text #<< "" << check_box_html
    # end

    def to_html
      input_wrapping do
        hidden_field_html <<
        label_html <<
        check_box_html
      end
    end

  end
end