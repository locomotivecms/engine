module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Extends

        attr_accessor :page_id # parent page id

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @template_name = $1.gsub('\'', '').strip
          else
            raise SyntaxError.new("Error in tag 'extends' - Valid syntax: extends [template]")
          end

          @context = context

          retrieve_parent_page

          # before parsing the embedded tokens, get editable elements from parent page
          @context[:page].merge_editable_elements_from_page(@context[:parent_page])

          super

          # puts "** after extends, @context[:templates] = #{@context[:templates].inspect}"
        end

        private

        def parse_parent_template
          page = @context[:parent_page]

          template = page.template

          # merge blocks ?
          blocks = find_blocks(template.root.nodelist)

          blocks.each_value do |block|
            block.send(:instance_variable_set, :"@context", @context)
            block.end_tag
          end

          @context[:snippets] = page.snippet_dependencies
          @context[:templates] = ([*page.template_dependencies] + [@page_id]).compact

          # puts "@context[:templates] = #{[*page.template_dependencies].inspect} + #{[@page_id].inspect} = #{@context[:templates].inspect}"

          template
        end

        def retrieve_parent_page
          if @template_name == 'parent'
            if @context[:cached_parent]
              @context[:parent_page] = @context[:cached_parent]
              @context[:cached_parent] = nil
            else
              @context[:parent_page] = @context[:page].parent
            end
          else
            @context[:parent_page] = @context[:cached_pages].try(:[], @template_name) ||
              @context[:site].pages.where(:fullpath => @template_name).first
          end

          raise PageNotFound.new("Page with fullpath '#{@template_name}' was not found") if @context[:parent_page].nil?

          # puts "** @page_id = #{@context[:parent_page].id}"

          @page_id = @context[:parent_page].id
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end