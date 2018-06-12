module Locomotive
  class EditorService < Struct.new(:site, :account, :page)

    include Locomotive::Concerns::ActivityService

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

    def remove_ids(json)
      remove_blocks_ids(remove_sections_id(json))
    end

    def remove_sections_id(json)
      JSON.parse(json).map{ |section| section.except('id') }.to_json
    end

    def remove_blocks_ids(json)
      JSON.parse(json).each{ |section| section["blocks"].map!{ |block| block.except("id") }}.to_json
    end

    def remove_site_blocks_ids(json)
      JSON.parse(json).each{ |k, section| puts section["blocks"].map!{ |block| block.except("id") }}.to_json
    end
  end
end
