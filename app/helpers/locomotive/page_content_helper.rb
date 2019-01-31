require 'digest'

module Locomotive
  module PageContentHelper

    def content_types_with_templates(site)
      site.content_types.order_by(title: 1).map do |content_type|
        pages = site.pages
          .only(:_id, :site_id, :title, :target_klass_name, :sections_dropzone_content, :sections_content)
          .where(target_klass_name: content_type.entries_class_name)
          .map do |page|
            {
              id:       page._id,
              title:    page.title,
              sections: page.all_sections_content
            }
          end

        next if pages.empty?

        {
          name:   content_type.name,
          slug:   content_type.slug,
          pages:  pages
        }
      end.compact
    end

    def sections_content(model, sections, definitions)
      source  = model.respond_to?(:title) ? :page : :site
      content = model.sections_content || {}

      (sections[:top] + sections[:bottom]).each do |attributes|
        next if attributes[:source] != source

        key, type = attributes[:key], attributes[:type]

        # no content yet? take the default one from the section definition
        if content[key].blank?
          definition = definitions.find { |definition| definition['type'] == type } || {}

          content[key] = definition['default'] || { 'settings' => {}, 'blocks' => [] }
        else
          content[key]['settings'] ||= {}
          content[key]['blocks']   ||= []
        end

        content[key]['id']    = attributes[:id] # FIXME: attributes[:id] => section domId
        content[key]['type']  = type # make sure there is always the type attribute

        # reset block id
        content[key]['blocks'] = (content[key]['blocks'] || []).each_with_index.map do |block, index|
          block['id'] = index.to_s
          block
        end
      end

      content
    end

    def sections_dropzone_content(page)
      (page.sections_dropzone_content || []).each_with_index.map do |section, index|
        section['id'] = "dropzone-#{index}"

        # FIXME: sections content deployed with Wagon might have no blocks (nil)
        section['blocks'] = (section['blocks'] || []).each_with_index.map do |block, _index|
          block['id'] = _index.to_s
          block
        end

        section
      end
    end

    def sections_by_id(sections, page)
      {}.tap do |ids|
        (sections[:top] + sections[:bottom]).each do |attributes|
          attributes[:uuid] = Digest::MD5.hexdigest(attributes[:id])

          ids[attributes[:uuid]] = attributes
        end

        (page.sections_dropzone_content || []).each_with_index do |section, index|
          id    = "dropzone-#{index}"
          uuid  = Digest::MD5.hexdigest(id)

          section[:uuid] = uuid

          ids[uuid] = {
            uuid:   uuid,
            id:     "dropzone-#{index}",
            type:   section['type'],
            source: 'dropzone'
          }
        end
      end
    end

  end
end
