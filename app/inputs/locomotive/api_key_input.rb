module Locomotive
  class ApiKeyInput
    include Formtastic::Inputs::Base

    def to_html
      input_wrapping do
        label_html <<
        api_key_html <<
        regenerate_button
      end
    end

    def input_wrapping(&block)
      template.content_tag(:li,
        [template.capture(&block), hint_html].join("\n").html_safe,
        wrapper_html_options
      )
    end

    def api_key_html
      api_key = self.object.api_key || I18n.t('locomotive.api_key.none')
      template.content_tag :code, api_key
    end

    def regenerate_button
      url = options[:url]
      template.content_tag :button, I18n.t('locomotive.api_key.button'),
        class:  'regenerate',
        data:   {
          url:      url,
          confirm:  I18n.t('locomotive.messages.confirm')
        }
    end

    def errors?
      false
    end

  end
end