module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Extends

        def parse_parent_template(context)
          page = context[:site].pages.where(:fullpath => @template_name.gsub("'", '')).first

          raise PageNotFound.new("Page with fullpath '#{@template_name}' was not found") if page.nil?

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