module Locomotive
  class EditorService < Struct.new(:site, :account, :page)

    include Locomotive::Concerns::ActivityService

    # Used by the URL picker to retrieve either a page or a content entry.
    def find_resources(query, max_results = 10)
      return [] if query.strip.blank?

      (
        site.pages
        .only(:_id, :title)
        .where(title: /#{query}/i, published: true, is_layout: false, target_klass_name: nil, :slug.ne => '404')
        .limit(max_results).map do |page|
          { type: 'page', value:  page._id, label: ['Pages', page.title] }
        end
      ) + (
        site.pages
        .only(:_id, :site_id, :target_klass_name)
        .where(:target_klass_name.ne => nil).map do |page|
          page.fetch_target_entries(
            page.content_type.label_field_name => /#{query}/i, visible: true
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

    # Save sections for both the current site (static versions) and
    # the page
    def save(site_attributes, page_attributes)
      site_attributes[:sections_content] = remove_site_blocks_ids(site_attributes[:sections_content])
      site.update_attributes(site_attributes)

      page_attributes[:sections_content] = remove_ids(page_attributes[:sections_content])

      page.update_attributes(page_attributes)

      track_activity 'editable_element.updated_bulk', parameters: {
        pages: [page].map { |p| { title: p.title, _id: p._id } }
      }
    end

    private

    def remove_ids(json)
      remove_blocks_ids(remove_sections_id(json))
    end

    def remove_sections_id(json)
      JSON.parse(json).map { |section| section.except('id') }.to_json
    end

    def remove_blocks_ids(json)
      JSON.parse(json).each{ |section| section["blocks"].map! { |block| block.except("id") } }.to_json
    end

    def remove_site_blocks_ids(json)
      JSON.parse(json).each{ |k, section| section["blocks"].map! { |block| block.except("id") } }.to_json
    end
  end
end
