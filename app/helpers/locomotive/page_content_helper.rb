module Locomotive
  module PageContentHelper

    def all_static_sections(section_types)
      section_types.without('_sections_dropzone_')
    end

    def all_static_sections_to_json(section_types)
      all_static_sections(section_types).to_json.html_safe
    end

    def top_static_sections(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.first
      end
    end

    def top_static_sections_to_json(section_types)
      top_static_sections(section_types).to_json.html_safe
    end

    def bottom_static_sections(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.last
      end
    end

    def bottom_static_sections_to_json(section_types)
      bottom_static_sections(section_types).to_json.html_safe
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

    def sections_content(page)
      page.sections_content.each_with_index.map do |section, index|
        section['id'] = index.to_s

        section['blocks'] = section['blocks'].each_with_index.map do |block, _index|
          block['id'] = _index.to_s
          block
        end

        section
      end
    end

    def sections_content_to_json(page)
      sections_content(page).to_json.html_safe
    end

  end
end
