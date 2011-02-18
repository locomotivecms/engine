module Locomotive
  module Liquid
    module Tags
      class SEOMetadata < ::Liquid::Tag

        def render(context)
          %{
            <meta name="description" content="#{sanitized_string(context.registers[:site].meta_description)}" />
            <meta name="keywords" content="#{sanitized_string(context.registers[:site].meta_keywords)}" />
          }
        end

        # Removes whitespace and quote charactets from the input
        def sanitized_string(string)
          string.strip.gsub(/"/, '')
        end

      end

      ::Liquid::Template.register_tag('seo_metadata', SEOMetadata)
    end
  end
end