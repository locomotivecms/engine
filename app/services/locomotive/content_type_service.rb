module Locomotive
  class ContentTypeService < Struct.new(:site)

    def list
      site
      .content_types
      .order_by(:'display_settings.position'.asc, :name.asc)
      .pluck(:_id, :name, :slug, :number_of_entries, :display_settings)
      .map do |(_id, name, slug, number_of_entries, display_settings)|
        Locomotive::ContentType.new(
          _id: _id,
          name: name,
          slug: slug,
          number_of_entries: number_of_entries,
          display_settings: display_settings
        )
      end
    end

    def find_by_slug(slug)
      site.content_types.by_id_or_slug(slug)
    end

    def update(content_type, attributes = {})
      content_type.update_attributes(attributes)
    end

  end
end
