module Locomotive
  module API
    module Forms

      class SiteForm < BaseForm

        attrs :name, :handle, :robots_txt, :locales, :domains, :url_redirections, :timezone, :picture, :cache_enabled, :private_access, :password, :asset_host
        attrs :metafields_schema, :metafields, :metafields_ui
        attrs :seo_title, :meta_keywords, :meta_description, localized: true
        attrs :section_content

        # Make sure locales and domains are in arrays.
        def locales
          [*@locales]
        end

        def domains
          [*@domains]
        end

        ## Custom setters ##

        def sections_content=(value)
          self.sections_content = JSON.parse(value)
        end

      end

    end
  end
end
