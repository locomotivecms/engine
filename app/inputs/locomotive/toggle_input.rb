module Locomotive
  class ToggleInput < FormtasticBootstrap::Inputs::BooleanInput

    def to_html
      form_group_wrapping do
        label_hint_error_html <<
        check_box_html
      end
    end

    def label_hint_error_html
      template.content_tag :div, label_html <<
        hint_html(:inline) <<
        error_html(:inline)
    end

    def check_box_html
      template.content_tag(:span, class: 'form-wrapper') do
        builder.check_box method, data: {
          'on-text'   => text(:on_text),
          'off-text'  => text(:off_text),
          'on-color'  => 'success',
          'off-color' => 'danger',
          'size'      => 'small'
        }
      end
    end

    def text(name)
      I18n.t(name, scope: 'locomotive.shared.form.toggle_input')
    end

  end
end