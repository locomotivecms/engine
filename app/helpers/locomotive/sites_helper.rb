module Locomotive
  module SitesHelper

    # forms

    def ordered_current_site_locales
      current_site.locales + (Locomotive.config.site_locales - current_site.locales)
    end

    def options_for_site_locales
      Rails.cache.fetch(base_cache_key_without_site + ['locales']) do
        (Locomotive.config.site_locales - [:ca, :"sv-FI"]).map do |locale|
          text          = I18n.t("locomotive.locales.#{locale}", default: locale)
          nice_display  = h("#{flag_tag(locale)} #{text} &ndash; #{locale}")

          [
            text,
            locale,
            { :"data-display" => nice_display.html_safe }
          ]
        end
      end
    end

    def options_for_site_timezones
      Rails.cache.fetch([Locomotive::VERSION, 'timezones']) do
        ActiveSupport::TimeZone.all.map do |tz|
          [tz.to_s, tz.name]
        end
      end
    end

  end
end
