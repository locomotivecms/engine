module Locomotive
  class EditorService < Struct.new(:site, :account, :page)

    include Locomotive::Concerns::ActivityService

    # Used by the URL picker to retrieve either a page or a content entry.
    def find_resources(query, max_results = 10)
      return [] if query.strip.blank?

      (
        site.pages
        .only(:_id, :title)
        .where(title: /#{query}/i, is_layout: false, target_klass_name: nil, :slug.ne => '404')
        .limit(max_results).map do |page|
          { type: 'page', value:  page._id, label: ['Pages', page.title] }
        end
      ) + (
        site.pages
        .only(:_id, :site_id, :target_klass_name)
        .where(:target_klass_name.ne => nil).map do |page|
          page.fetch_target_entries(
            page.content_type.label_field_name => /#{query}/i, _visible: true
          ).map do |entry|
            {
              type:   'content_entry',
              value:  { content_type_slug: entry.content_type_slug, id: entry._id, page_id: page._id },
              label:  [entry.content_type.name, entry._label]
            }
          end
        end.flatten
      )
      .sort { |a, b| a[:label][1] <=> b[:label][1] }
      .first(max_results)
    end

    # Save sections for both the current site (global versions) and the page
    def save(site_attributes, page_attributes)
      site_attributes[:sections_content] = parse_sections_content(site_attributes[:sections_content])
      site.update_attributes(site_attributes)

      page_attributes[:sections_content]          = parse_sections_content(page_attributes[:sections_content])
      page_attributes[:sections_dropzone_content] = parse_sections_dropzone_content(page_attributes[:sections_dropzone_content])
      page.update_attributes(page_attributes)

      track_activity 'editable_element.updated_bulk', parameters: {
        pages: [page].map { |p| { title: p.title, _id: p._id } }
      }
    end

    private

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
