module Locomotive
  class ToggleInput < SimpleForm::Inputs::Base

    def input(wrapper_options)
      template.content_tag(:span, class: 'form-wrapper') do
        @builder.check_box attribute_name, data: {
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
