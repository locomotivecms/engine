module Locomotive
  module PageContentHelper

    def all_static_sections_to_json(section_types)
      section_types.without('_sections_dropzone_').to_json.html_safe
    end

    def top_static_sections_to_json(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.first
      end.to_json.html_safe
    end

    def bottom_static_sections_to_json(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.last
      end.to_json.html_safe
    end

    def static_sections_content(site, types, definitions)
      content = site.sections_content || {}

      types.each do |type|
        next if type == '_sections_dropzone_'

        # no content yet?
        if content[type].blank?
          definition = definitions.find { |definition| definition['type'] == type }

          content[type] = definition['default'] || { 'settings' => {}, 'blocks' => [] }
        else
          content[type]['settings'] ||= {}
          content[type]['blocks']   ||= []
        end

        # assign an id to each block of static sections
        content[type]['blocks'] = content[type]['blocks'].each_with_index.map do |block, index|
          block['id'] = index.to_s
          block
        end
      end

      content
    end

    def static_sections_content_to_json(site, names, definitions)
      static_sections_content(site, names, definitions).to_json.html_safe
    end

  end
end
