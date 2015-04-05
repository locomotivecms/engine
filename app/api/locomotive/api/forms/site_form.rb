module Locomotive
  module API
    module Forms

      class SiteForm < BaseForm

        attrs :name, :handle, :seo_title, :meta_keywords, :meta_description,
              :robots_txt, :locales, :domains, :timezone


        # Make sure locales and domains are in arrays.
        def locales
          [*@locales]
        end

        def domains
          [*@locales]
        end

      end

    end
  end
end
