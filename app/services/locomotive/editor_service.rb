module Locomotive
  class EditorService < Struct.new(:site, :account, :page)

    include Locomotive::Concerns::ActivityService

    # Save sections for both the current site (static versions) and
    # the page
    def save(site_attributes, page_attributes)
      site.update_attributes(site_attributes)

      page_attributes[:sections_content] = EditorService.remove_ids(page_attributes[:sections_content])
      page.update_attributes(page_attributes)

      track_activity 'editable_element.updated_bulk', parameters: {
        pages: [page].map { |p| { title: p.title, _id: p._id } }
      }
    end

    def self.remove_ids(json)
      json = remove_sections_id(json)
      json = remove_blocks_ids(json)
      return json
    end

    def self.remove_sections_id(json)
      JSON.parse(json).map{|j| j.except('id')}.to_json
    end

    def self.remove_blocks_ids(json)
      JSON.parse(json).each{|j| j["blocks"].map!{|v| v.except("id")}}.to_json
    end
  end
end
