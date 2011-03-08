module Locomotive
  module Liquid
    module Tags
      # Display the children pages of the site, current page or the parent page. If not precised, nav is applied on the current page.
      # The html output is based on the ul/li tags.
      #
      # Passing through depth will control how many nested children are output
      #
      # Usage:
      #
      # {% nav site %} => <ul class="nav"><li class="on"><a href="/features">Features</a></li></ul>
      #
      # {% nav site, no_wrapper: true, depth: 1, exclude: 'contact|about', id: 'main-nav' }
      #
      class Nav < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @source = ($1 || 'page').gsub(/"|'/, '')
            @options = { :id => 'nav', :depth => 1 }
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

            children_output << render_entry_link(p, css.join(' '), 1)
          end

          output = children_output.join("\n")

          if @options[:no_wrapper] != 'true'
            output = %{<ul id="#{@options[:id]}">\n#{output}</ul>}
          end

          output
        end

        private

        # Determines root node for the list
        def fetch_entries(context)
          @current_page = context.registers[:page]

          children = (case @source
          when 'site'     then context.registers[:site].pages.root.minimal_attributes.first # start from home page
          when 'parent'   then @current_page.parent || @current_page
          when 'page'     then @current_page
          else
            context.registers[:site].pages.fullpath(@source).minimal_attributes.first
          end).children_with_minimal_attributes.to_a

          children.delete_if { |p| !include_page?(p) }
        end

        # Returns a list element, a link to the page and its children
        def render_entry_link(page, css, depth)
          selected = @current_page.fullpath =~ /^#{page.fullpath}/ ? ' on' : ''

          icon = @options[:icon] ? '<span></span>' : ''
          label = %{#{icon if @options[:icon] != 'after' }#{page.title}#{icon if @options[:icon] == 'after' }}

          output  = %{<li id="#{page.slug.dasherize}-link" class="link#{selected} #{css}">}
          output << %{<a href="/#{page.fullpath}">#{label}</a>}
          output << render_entry_children(page, depth.succ) if (depth.succ <= @options[:depth].to_i)
          output << %{</li>}

          output.strip
        end

        # Recursively creates a nested unordered list for the depth specified
        def render_entry_children(page, depth)
          output = %{}

          children = page.children_with_minimal_attributes.reject { |c| !include_page?(c) }
          if children.present?
            output = %{<ul id="#{@options[:id]}-#{page.slug.dasherize}">}
            children.each do |c, page|
              css = []
              css << 'first' if children.first == c
              css << 'last'  if children.last  == c

              output << render_entry_link(c, css.join(' '), depth)
            end
            output << %{</ul>}
          end

          output
        end

        # Determines whether or not a page should be a part of the menu
        def include_page?(page)
          if !page.listed? || page.templatized? || !page.published?
            false
          elsif @options[:exclude]
            (page.fullpath =~ @options[:exclude]).nil?
          else
            true
          end
        end

        ::Liquid::Template.register_tag('nav', Nav)
      end
    end
  end
end
