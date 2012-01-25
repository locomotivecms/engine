module Locomotive::SitesHelper

  def ordered_current_site_locales
    current_site.locales + (Locomotive.config.site_locales - current_site.locales)
  end

end
