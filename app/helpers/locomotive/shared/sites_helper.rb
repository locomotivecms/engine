module Locomotive
  module Shared
    module SitesHelper

      def multi_sites?
        Locomotive.config.multi_sites?
      end

      def site_picture_url(site, size = '80x80#')
        if site.picture?
          Locomotive::Dragonfly.resize_url site.picture.url, size
        else
          'locomotive/site.png'
        end
      end

    end
  end
end
