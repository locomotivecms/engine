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
      # {% nav site, no_wrapper: true, exclude: 'contact|about', id: 'main-nav', class: 'nav', active_class: 'on' }
      #
      class Nav < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @source = ($1 || 'page').gsub(/"|'/, '')
            @options = { :id => 'nav', :depth => 1, :class => '', :active_class => 'on', :bootstrap => false }
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

            @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]

            @options[:add_attributes] = []
            if @options[:snippet]
              template = @options[:snippet].include?('{') ? @options[:snippet] : context[:site].snippets.where(:slug => @options[:snippet] ).try(:first).try(:template)
              unless template.blank?
                @options[:liquid_render] = ::Liquid::Template.parse(template)
                @options[:add_attributes] = ['editable_elements']
              end
            end

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
            list_class  = !@options[:class].blank? ? %( class="#{@options[:class]}") : ''
            output      = %{<ul id="#{@options[:id]}"#{list_class}>\n#{output}</ul>}
          end

          output
        end

        private

        # Determines root node for the list
        def fetch_entries(context)
          @site, @page = context.registers[:site], context.registers[:page]

          children = (case @source
          when 'site'     then @site.pages.root.minimal_attributes(@options[:add_attributes]).first # start from home page
          when 'parent'   then @page.parent || @page
          when 'page'     then @page
          else
            @site.pages.fullpath(@source).minimal_attributes(@options[:add_attributes]).first
          end).children_with_minimal_attributes(@options[:add_attributes]).to_a

          children.delete_if { |p| !include_page?(p) }
        end

        # Returns a list element, a link to the page and its children
        def render_entry_link(page, css, depth)
          selected = @page.fullpath =~ /^#{page.fullpath}/ ? " #{@options[:active_class]}" : ''

          icon = @options[:icon] ? '<span></span>' : ''

          title = @options[:liquid_render] ? @options[:liquid_render].render('page' => page) : page.title

          label = %{#{icon if @options[:icon] != 'after' }#{title}#{icon if @options[:icon] == 'after' }}

          link_options = caret = ''
          href = File.join('/', @site.localized_page_fullpath(page))

          if render_children_for_page?(page, depth) && bootstrap?
            css           += ' dropdown'
            link_options  = %{ class="dropdown-toggle" data-toggle="dropdown"}
            href          = '#'
            caret         = %{ <b class="caret"></b>}
          end

          output  = %{<li id="#{page.slug.to_s.dasherize}-link" class="link#{selected} #{css}">}
          output << %{<a href="#{href}"#{link_options}>#{label}#{caret}</a>}
          output << render_entry_children(page, depth.succ) if (depth.succ <= @options[:depth].to_i)
          output << %{</li>}

          output.strip
        end

        def render_children_for_page?(page, depth)
          depth.succ <= @options[:depth].to_i && page.children.reject { |c| !include_page?(c) }.any?
        end

        # Recursively creates a nested unordered list for the depth specified
        def render_entry_children(page, depth)
          output = %{}

          children = page.children_with_minimal_attributes(@options[:add_attributes]).reject { |c| !include_page?(c) }
          if children.present?
            output = %{<ul id="#{@options[:id]}-#{page.slug.to_s.dasherize}" class="#{bootstrap? ? 'dropdown-menu' : ''}">}
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

        def bootstrap?
          @options[:bootstrap] == 'true'
        end

      end

      ::Liquid::Template.register_tag('nav', Nav)
    end
  end
end
