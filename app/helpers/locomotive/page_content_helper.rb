module Locomotive
  module PageContentHelper

    def static_sections_content(site, types, definitions)
      content = site.sections_content || {}

      types.each do |type|
        # no content yet?
        if content[type].blank?
          definition = definitions.find { |definition| definition['type'] == type }

          content[type] = definition['default'] || { settings: {}, blocks: [] }
        end
      end

      content
    end

    def static_sections_content_to_json(site, names, definitions)
      static_sections_content(site, names, definitions).to_json.html_safe
    end

  end
end
