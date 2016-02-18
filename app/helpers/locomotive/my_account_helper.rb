module Locomotive
  module MyAccountHelper

    def options_for_locale
      Rails.cache.fetch("#{Locomotive::VERSION}/views/helpers/options_for_locale") do
        Locomotive.config.locales.map do |locale|
          flag_url = path_to_image "locomotive/icons/flags/#{locale}.png"

          [
            I18n.t("locomotive.locales.#{locale}"),
            locale,
            { :"data-flag" => flag_url }
          ]
        end
      end
    end

  end
end
