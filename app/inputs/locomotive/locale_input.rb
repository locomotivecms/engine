module Locomotive
  class LocaleInput < Formtastic::Inputs::TextInput

    def to_html
      input_wrapping do
        label_html <<
        self.available_locales_to_html
      end
    end

    def available_locales_to_html
      template.content_tag(:div,
        Locomotive.config.locales.map do |locale|
          template.content_tag(:div, locale_to_html(locale).html_safe, :class => 'entry')
        end.join.html_safe, :class => 'list')
    end

    def locale_to_html(locale)
      text = I18n.t("locomotive.my_account.edit.#{locale}")

      builder.radio_button(:locale, locale) +
      template.content_tag(:label,
        template.image_tag("locomotive/icons/flags/#{locale}.png", :alt => text) +
        text)
    end

  end
end