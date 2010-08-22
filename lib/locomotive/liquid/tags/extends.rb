module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Extends

        attr_accessor :page_id

        def parse_parent_template(context)
          page = nil

          if @template_name == 'parent'
            if context[:cached_parent]
              page = context[:cached_parent]
              context[:cached_parent] = nil
            else
              page = context[:page].parent
            end
          else
            path = @template_name.gsub("'", '')
            page = context[:cached_pages].try(:[], path) || context[:site].pages.where(:fullpath => path).first
          end

          raise PageNotFound.new("Page with fullpath '#{@template_name}' was not found") if page.nil?

          @page_id = page.id

          template = page.template

          # merge blocks ?
          blocks = find_blocks(template.root.nodelist)

          blocks.each_value do |block|
            block.send(:instance_variable_set, :"@context", context)
            block.end_tag
          end

          template
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end