module Locomotive
  module Liquid
    module Tags
      # Display the children pages of the site, current page or the parent page. If not precised, nav is applied on the current page.
      # The html output is based on the ul/li tags.
      #
      # Usage:
      #
      # {% nav site %} => <ul class="nav"><li class="on"><a href="/features">Features</a></li></ul>
      #
      # {% nav site, no_wrapper: true, exclude: 'contact|about', id: 'main-nav' }
      #
      class Nav < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @source = ($1 || 'page').gsub(/"|'/, '')
            @options = { :id => 'nav' }
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

            @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'nav' - Valid syntax: nav <page|site> <options>")
          end

          super
        end

        def render(context)
          children_output = []

          entries = fetch_entries(context)

          entries.each_with_index do |p, index|
            css = []
            css << 'first' if index == 0
            css << 'last' if index == entries.size - 1

            children_output << render_entry_link(p, css.join(' '))
          end

          output = children_output.join("\n")

          if @options[:no_wrapper] != 'true'
            output = %{<ul id="#{@options[:id]}">\n#{output}</ul>}
          end

          output
        end

        private

        def fetch_entries(context)
          @current_page = context.registers[:page]

          children = (case @source
          when 'site'     then context.registers[:site].pages.index.minimal_attributes.first # start from home page
          when 'parent'   then @current_page.parent || @current_page
          when 'page'     then @current_page
          else
            context.registers[:site].pages.fullpath(@source).minimal_attributes.first
          end).children_with_minimal_attributes.to_a

          children.delete_if { |p| !include_page?(p) }
        end

        def include_page?(page)
          if page.templatized? || !page.published?
            false
          elsif @options[:exclude]
            (page.fullpath =~ @options[:exclude]).nil?
          else
            true
          end
        end

        def render_entry_link(page, css)
          selected = @current_page.fullpath =~ /^#{page.fullpath}/ ? ' on' : ''

          icon = @options[:icon] ? '<span></span>' : ''
          label = %{#{icon if @options[:icon] != 'after' }#{page.title}#{icon if @options[:icon] == 'after' }}

          %{
            <li id="#{page.slug.dasherize}" class="link#{selected} #{css}">
              <a href="/#{page.fullpath}">#{label}</a>
            </li>
          }.strip
        end

        ::Liquid::Template.register_tag('nav', Nav)
      end
    end
  end
end
