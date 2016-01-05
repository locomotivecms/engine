module Locomotive
  class ApiKeyInput < ::SimpleForm::Inputs::Base

    include Locomotive::SimpleForm::Inputs::FasterTranslate

    def input(wrapper_options)
      api_key_html + regenerate_button
    end

    def api_key_html
      api_key = object.api_key || I18n.t('simple_form.labels.locomotive.account.no_api_key')
      template.content_tag :code, api_key
    end

    def regenerate_button
      url = options[:url]
      template.content_tag :button, I18n.t('simple_form.buttons.locomotive.account.new_api_key'),
        class:  'btn btn-default btn-sm form-control-button',
        data:   {
          url:      url,
          confirm:  I18n.t('locomotive.messages.confirm')
        }
    end

  end
end
