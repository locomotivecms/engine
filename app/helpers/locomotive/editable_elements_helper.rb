module Locomotive
  module EditableElementsHelper

    def each_editable_element(blocks, elements_by_block)
      blocks.each_with_index do |block, block_index|
        elements_by_block[block[:name]].each_with_index do |(page, element), el_index|
          index = block_index * 100 + el_index
          yield(page, element, index)
        end
      end
    end

    def editable_text_format_to_input_type(editable_element)
      case editable_element.format
      when 'html'     then :rte
      when 'markdown' then :markdown
      else :text
      end
    end

    def editable_element_input_options(editable_element, index, options = {})
      {
        label:        editable_element_label(editable_element),
        placeholder:  false,
        hint:         editable_element.hint,
        wrapper_html: {
          id:   "#{editable_element.type.to_s.dasherize}-#{editable_element._id}",
          data: { block: editable_element.block || '', path: editable_element.path }
        }
      }.merge(options)
    end

    def editable_element_label(editable_element)
      label = <<-HTML
      <span class="label label-primary">#{editable_element.block_label}</span>
      &nbsp;
      #{editable_element.label}
      HTML

      label.html_safe
    end

    def nice_editable_elements_path
      preview_page_path(@page)
    end

    def options_for_page_blocks(blocks)
      options_for_select(
        [[t(:all, scope: 'locomotive.editable_elements.edit.blocks'), '']] +
        blocks.map do |block|
          block[:name].nil? ? [t(:unknown, scope: 'locomotive.editable_elements.edit.blocks'), '_unknown'] : [block[:label], block[:name]]
        end)
    end

    def page_locale_picker_link(page, content_entry)
      service = Locomotive::Steam::Services.build_instance
      _page   = Locomotive::Steam::Decorators::PageDecorator.new(page.to_steam, current_content_locale, current_site.default_locale)

      _page.content_entry   = content_entry
      service.current_site  = current_site

      base_params = @content_entry ? "content_entry_id=#{@content_entry.try(:_id)}" : ""

      locale_picker_link do |locale|
        url = service.url_builder.url_for(_page, locale)[1..-1]
        "?content_locale=#{locale}&preview_path=#{url}&#{base_params}"
      end
    end

  end
end
