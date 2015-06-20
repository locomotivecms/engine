module Locomotive

  class EditableElementService < Struct.new(:site, :account)

    def update_all(elements)
      pages = {}

      elements.values.each do |attributes|
        page_id = attributes[:page_id]

        if page = (pages[page_id] || Locomotive::Page.find(page_id))
          pages[page_id] = page

          if element = page.editable_elements.find(attributes[:id])
            element.attributes = clean_attributes_for(element, attributes)
          end
        end
      end

      save_all_pages(pages.values)
    end

    private

    def save_all_pages(pages)
      pages.all? do |page|
        page.updated_by = account
        page.save
      end
    end

    def clean_attributes_for(element, attributes)
      case element
      when Locomotive::EditableFile
        attributes.delete(:source) if attributes[:source] == 'undefined'
        attributes.slice(:source, :remove_source, :remote_source_url)
      when Locomotive::EditableText
        attributes.slice(:content)
      end
    end

  end

end
