module Locomotive
  module API
    module Entities

      class SiteEntity < BaseEntity

        expose    :name, :handle, :seo_title, :meta_keywords, :meta_description,
                  :robots_txt

        expose :locales, :domains

        expose :memberships, using: MembershipEntity

        expose :timezone do |site, _|
          site.timezone_name
        end

      end

    end
  end
end
