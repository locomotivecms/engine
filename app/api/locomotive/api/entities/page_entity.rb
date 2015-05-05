module Locomotive
  module API
    module Entities

      class PageEntity < BaseEntity

        expose  :title, :parent_id, :position,
                :handle, :depth, :response_type,
                :listed, :published, :translated_in

        # Path
        expose :slug, :fullpath

        expose :localized_fullpaths do |page, options|
          (options[:site].try(:locales) || []).inject({}) do |hash, locale|
            hash.merge(locale => site.localized_page_fullpath(page, locale))
          end

          # if (site = options[:site])
          #   {}.tap do |hash|
          #     site.locales.each do |locale|
          #       hash[locale] = site.localized_page_fullpath(page, locale)
          #     end
          #   end
          # else
          #   {}
          # end
        end

        # Redirection
        expose :redirect, :redirect_url, :redirect_type

        # Templatized page (related to a content type)
        expose :templatized, :templatized_from_parent

        expose :content_type do |page, _|
          page.content_type.try(:slug)
        end

        # Layout / Template
        expose :is_layout, :allow_layout

        expose :template do |page, _|
          page.raw_template
        end

        # Editable elements
        expose :editable_elements, using: EditableElementEntity

        # SEO
        expose :seo_title, :meta_keywords, :meta_description

      end

    end
  end
end
