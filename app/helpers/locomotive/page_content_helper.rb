module Locomotive
  module PageContentHelper

    def all_static_sections(section_types)
      section_types.without('_sections_dropzone_')
    end

    def top_static_sections(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.first
      end
    end

    def bottom_static_sections(section_types)
      if (array = section_types.split('_sections_dropzone_')).size == 1
        []
      else
        array.last
      end
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

    def sections_dropzone_content(page)
      page.sections_dropzone_content.each_with_index.map do |section, index|
        section['id'] = index.to_s

        section['blocks'] = section['blocks'].each_with_index.map do |block, _index|
          block['id'] = _index.to_s
          block
        end

        section
      end
    end

    # TODO: sections_content
    # def sections_content(page)
    #   page.sections_content.each_with_index.map do |section, index|
    #     section['id'] = index.to_s

    #     section['blocks'] = section['blocks'].each_with_index.map do |block, _index|
    #       block['id'] = _index.to_s
    #       block
    #     end

    #     section
    #   end
    # end

  end
end
