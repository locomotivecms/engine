module Locomotive
  module EditableElementsHelper

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
