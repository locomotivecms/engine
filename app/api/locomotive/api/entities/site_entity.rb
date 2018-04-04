module Locomotive
  module API
    module Entities

      class SiteEntity < BaseEntity

        expose  :name, :handle, :seo_title, :meta_keywords, :meta_description,
                :robots_txt, :cache_enabled, :private_access

        expose :locales, :domains, :asset_host, :url_redirections

        expose :memberships, using: MembershipEntity

        expose :timezone do |site, _|
          site.timezone_name
        end

        expose :picture_url do |site, _|
          site.picture.url
        end

        expose :content_version do |site, _|
          site.content_version.to_i
        end

        expose :template_version do |site, _|
          site.template_version.to_i
        end

        expose :picture_thumbnail_url do |site, _|
          Locomotive::Dragonfly.resize_url site.picture.url, '100x100#'
        end

        expose :preview_url do |site, opts|
          Locomotive::Engine.routes.url_helpers.preview_url(site, host: opts[:env]['HTTP_HOST'])
        end

        expose :sign_in_url do |site, opts|
          Locomotive::Engine.routes.url_helpers.new_locomotive_account_session_url(host: opts[:env]['HTTP_HOST'])
        end

        expose :metafields do |site, opts|
          site.metafields.to_json
        end

        expose :metafields_schema do |site, opts|
          site.metafields_schema.to_json
        end

        expose :metafields_ui do |site, opts|
          site.metafields_ui.to_json
        end

      end

    end
  end
end
