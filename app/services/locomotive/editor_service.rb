module Locomotive
  class EditorService < Struct.new(:site, :account, :page)

    include Locomotive::Concerns::ActivityService

    # Save sections for both the current site (static versions) and
    # the page
    def save(site_attributes, page_attributes)
      site.update_attributes(site_attributes)

      page.update_attributes(page_attributes)

      track_activity 'editable_element.updated_bulk', parameters: {
        pages: [page].map { |p| { title: p.title, _id: p._id } }
      }
    end

  end
end
