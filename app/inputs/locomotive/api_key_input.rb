module Locomotive
  class ApiKeyInput < Formtastic::Inputs::StringInput

    include FormtasticBootstrap::Inputs::Base
    include FormtasticBootstrap::Inputs::Base::Stringish

    def to_html
      bootstrap_wrapping do
        api_key_html <<
        regenerate_button
      end
    end

    def api_key_html
      api_key = self.object.api_key || I18n.t('locomotive.api_key.none')
      template.content_tag :code, api_key
    end

    def regenerate_button
      url = options[:url]
      template.content_tag :button, I18n.t('locomotive.api_key.button'),
        class:  'btn btn-default btn-sm',
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