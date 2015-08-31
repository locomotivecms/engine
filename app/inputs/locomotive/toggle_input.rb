module Locomotive
  class ToggleInput < ::SimpleForm::Inputs::Base

    include Locomotive::SimpleForm::Inputs::FasterTranslate

    def input(wrapper_options)
      template.content_tag(:div, class: 'toggle-wrapper') do
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
      I18n.t(name, scope: 'locomotive.inputs.toggle')
    end

  end
end
