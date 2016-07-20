module Locomotive
  module API
    module Forms

      class SiteForm < BaseForm

        attrs :name, :handle, :robots_txt, :locales, :domains, :timezone, :picture, :cache_enabled, :private_access, :password, :metafields_schema, :metafields, :metafields_ui, :is_theme, :theme_name
        attrs :seo_title, :meta_keywords, :meta_description, localized: true

        # Make sure locales and domains are in arrays.
        def locales
          [*@locales]
        end

        def domains
          [*@domains]
        end

      end

    end
  end
end
