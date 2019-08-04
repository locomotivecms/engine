module Locomotive
  module API
    module Forms

      class SiteForm < BaseForm

        attrs :name, :handle, :robots_txt, :domains, :routes, :url_redirections, :timezone_name, :picture, :private_access, :password, :asset_host
        attrs :metafields_schema, :metafields, :metafields_ui
        attrs :locales, :prefix_default_locale, :bypass_browser_locale
        attrs :seo_title, :meta_keywords, :meta_description, localized: true
        attrs :cache_enabled, :cache_control, :cache_vary
        attrs :sections_content

        # Make sure locales and domains are in arrays.
        def locales
          [*@locales]
        end

        def domains
          [*@domains]
        end

        ## Custom setters ##

        def timezone=(value)
          self.timezone_name = value
        end

        def sections_content=(value)
          set_attribute(:sections_content, value.is_a?(String) ? parse_json(value, {}) : value)
        end

        def routes=(value)
          set_attribute(:routes, value.is_a?(String) ? parse_json(value, []) : value)
        end

        private

        def parse_json(string, default_value = nil)
          JSON.parse(string) rescue default_value
        end

      end

    end
  end
end
