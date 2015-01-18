module Locomotive
  module Shared
    module SitesHelper

      def site_picture_url(site, size = '80x80#')
        if site && site.picture?
          Locomotive::Dragonfly.resize_url site.picture.url, size
        else
          'locomotive/site.png'
        end
      end

    end
  end
end
