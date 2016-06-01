module Locomotive
  module MyAccountHelper

    def options_for_locale
      Locomotive.config.locales.map do |locale|
        [
          I18n.t("locomotive.locales.#{locale}"),
          locale,
          {}
        ]
      end
    end

  end
end
