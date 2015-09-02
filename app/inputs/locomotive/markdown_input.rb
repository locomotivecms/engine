module Locomotive
  class MarkdownInput < Locomotive::RteInput

    def input(wrapper_options)
      input_html_options[:class] << 'form-control'
      toolbar_html + @builder.text_area(attribute_name, input_html_options)
    end

    def toolbar_html
      template.render(
        partial:  'locomotive/shared/rte/markdown_toolbar',
        locals:   {
          wysihtml5_prefix: wysihtml5_prefix,
          image_popover:    image_popover,
        })
    end

  end
end
