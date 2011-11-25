module Locomotive
  class ToggleInput < Formtastic::Inputs::BooleanInput

    def to_html
      input_wrapping do
        hidden_field_html <<
        label_html <<
        check_box_html
      end
    end

  end
end