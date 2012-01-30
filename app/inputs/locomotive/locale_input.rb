module Locomotive
  class LocaleInput < Formtastic::Inputs::TextInput

    include Formtastic::Inputs::Base::Choices

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
      text = I18n.t("locomotive.locales.#{locale}")

      builder.radio_button(:locale, locale, :id => choice_input_dom_id(locale)) +
      template.content_tag(:label,
        template.image_tag("locomotive/icons/flags/#{locale}.png", :alt => text) +
        text, :for => choice_input_dom_id(locale))
    end

    def choice_input_dom_id(choice)
      [
        builder.custom_namespace,
        sanitized_object_name,
        association_primary_key || method,
        choice_html_safe_value(choice)
      ].compact.reject { |i| i.blank? }.join("_")
    end

  end
end