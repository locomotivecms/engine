module Locomotive
  module API
    module Entities

      class SiteEntity < BaseEntity

        expose    :name, :handle, :seo_title, :meta_keywords, :meta_description,
                  :robots_txt, :cache_enabled

        expose :locales, :domains

        expose :memberships, using: MembershipEntity

        expose :timezone do |site, _|
          site.timezone_name
        end

        expose :picture_url do |site, _|
          site.picture.url
        end

        expose :picture_thumbnail_url do |site, _|
          Locomotive::Dragonfly.resize_url site.picture.url, '100x100#'
        end

      end

    end
  end
end
