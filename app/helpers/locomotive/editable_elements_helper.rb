module Locomotive
  module EditableElementsHelper

    def editable_element_input_options(editable_element, index, options = {})
      {
        label:        editable_element.slug,
        placeholder:  false,
        hint:         editable_element.hint,
        wrapper_html: {
          id:   "#{editable_element.type.to_s.dasherize}-#{index}",
          data: { block: editable_element.block || '' }
        }
      }.merge(options)
    end

    def nice_editable_elements_path
      _path = params[:preview_path] || current_site.localized_page_fullpath(@page)
      _path = 'index' if _path.blank?

      truncate('/' + _path, length: 50)
    end

    def ordered_editable_elements(editable_elements_by_block)
      list = []
      @editable_elements_by_block.each do |block, editable_elements|
        list += editable_elements.sort { |(page, element)| element.priority || 1 }
      end
      list
    end

    def options_for_page_blocks(editable_elements_by_block)
      options_for_select(
        [[t('.blocks.all'), '']] +
        editable_elements_by_block.keys.map do |name|
          name.nil? ? [t('.blocks.unknown'), '_unknown'] : [name, name]
        end)
    end

  end
end
