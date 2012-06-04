module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Extends

        def prepare_parsing
          super

          parent_page = @context[:parent_page]

          @context[:page].merge_editable_elements_from_page(parent_page)

          @context[:snippets] = parent_page.snippet_dependencies
          @context[:templates] = ([*parent_page.template_dependencies] + [parent_page.id]).compact
        end

        private

        def parse_parent_template
          if @template_name == 'parent'
            @context[:parent_page] = @context[:cached_parent] || @context[:page].parent
          else
            locale = ::Mongoid::Fields::I18n.locale

            @context[:parent_page] = @context[:cached_pages].try(:[], @template_name) ||
              @context[:site].pages.where("fullpath.#{locale}" => @template_name).first
          end

          raise PageNotFound.new("Page with fullpath '#{@template_name}' was not found") if @context[:parent_page].nil?

          # be sure to work with a copy of the parent template otherwise there will be conflicts
          parent_template = @context[:parent_page].template.try(:clone)

          raise PageNotTranslated.new("Page with fullpath '#{@template_name}' was not translated") if parent_template.nil?

          # force the page to restore the original version of its template (from the serialized version)
          @context[:parent_page].instance_variable_set(:@template, nil)

          parent_template
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end