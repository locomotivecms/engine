module Locomotive
  class EditorService < Struct.new(:site, :account, :page, :locale)

    include Locomotive::Concerns::ActivityService

    # Used by the URL picker to retrieve either a page or a content entry.
    def find_resources(type, query, scope = nil, max_results = 10)
      return [] if type.blank? || query.strip.blank?

      case type
      when 'page'
        find_pages(query, max_results)
      when 'content_entry'
        find_content_entries(scope, query, max_results)
      else
        Rails.logger.warn("[EditorService] Unknown type: #{type}")
        []
      end
    end

    # Save sections for both the current site (global versions) and the page
    def save(site_attributes, page_attributes)
      site_attributes[:sections_content] = parse_sections_content(site_attributes[:sections_content])
      site.update_attributes(site_attributes)

      page_attributes[:sections_content]          = parse_sections_content(page_attributes[:sections_content])
      page_attributes[:sections_dropzone_content] = parse_sections_dropzone_content(page_attributes[:sections_dropzone_content])
      page.update_attributes(page_attributes)

      track_activity 'page_content.updated',
        parameters: { _id: page._id, title: page.title },
        locale: locale
    end

    private

    def find_pages(query, max_results = 10)
      site.pages
      .only(:_id, :title, :sections_dropzone_content, :sections_content)
      .where(is_layout: false, target_klass_name: nil, :slug.ne => '404')
      .or({ title: /#{query}/i }, { _id: query })
      .limit(max_results)
      .sort(title: 1).map do |page|
        {
          type:     'page',
          value:    page._id,
          label:    ['Page', page.title],
          sections: page.all_sections_content
        }
      end
    end

    def find_content_entries(scope, query, max_results)
      content_type = site.content_types.where(slug: scope).first
      content_type.entries
      .where(
        content_type.label_field_name => /#{query}/i, _visible: true
      )
      .limit(max_results).map do |entry|
        {
          type:   'content_entry',
          value:  { content_type_slug: scope, id: entry._id },
          label:  [content_type.name, entry._label]
        }
      end
    end

    def parse_sections_content(value)
      return nil if value.nil?

      JSON.parse(value).tap do |sections|
        sections.values.each do |section|
          remove_section_ids(section)
          remove_blocks_ids(section['blocks'])
        end
      end
    end

    def parse_sections_dropzone_content(value)
      return nil if value.nil?

      JSON.parse(value).tap do |sections|
        sections.each do |section|
          remove_section_ids(section)
          remove_blocks_ids(section['blocks'])
        end
      end
    end

    def remove_section_ids(section)
      section.delete('id')
      section.delete('uuid')
    end

    def remove_blocks_ids(list)
      (list || []).each { |block| block.delete('id') }
    end

  end
end
