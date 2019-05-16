module Locomotive
  module DashboardHelper

    def current_site_url
      if current_site.domains.blank?
        preview_url(current_site)
      else
        protocol = current_site.redirect_to_https? ? 'https' : 'http'
        URI.join("#{protocol}://" + current_site.domains.first).tap do |uri|
          uri.port = request.port if request.port != 80 && request.port != 443
        end.to_s
      end
    end

  end
end
