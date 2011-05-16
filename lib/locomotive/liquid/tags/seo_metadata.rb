module Locomotive
  module Liquid
    module Tags
      class SEOMetadata < ::Liquid::Tag

        def render(context)
          %{
            <meta name="description" content="#{sanitized_string(meta_description(context))}" />
            <meta name="keywords" content="#{sanitized_string(meta_keywords(context))}" />
          }
        end

        # Removes whitespace and quote charactets from the input
        def sanitized_string(string)
          string.strip.gsub(/"/, '')
        end

        def meta_description(context)
          object = metadata_object(context)
          object.try(:meta_description).blank? ? context.registers[:site].meta_description : object.meta_description
        end

        def meta_keywords(context)
          object = metadata_object(context)
          object.try(:meta_keywords).blank? ? context.registers[:site].meta_keywords : object.meta_keywords
        end

        def metadata_object(context)
          context['content_instance'] || context['page']
        end
      end

      ::Liquid::Template.register_tag('seo_metadata', SEOMetadata)
    end
  end
end