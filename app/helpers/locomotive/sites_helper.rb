module Locomotive
  module SitesHelper

    def ordered_current_site_locales
      current_site.locales + (Locomotive.config.site_locales - current_site.locales)
    end

    def options_for_site_locales
      Locomotive.config.site_locales.map do |locale|
        [I18n.t("locomotive.locales.#{locale}"), locale]
      end
    end

  end
end