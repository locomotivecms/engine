module Locomotive
  module Liquid    
    module Tags    
      # Display the children pages of the site or the current page. If not precised, nav is applied on the current page.
      # The html output is based on the ul/li tags.
      #
      # Usage:
      #
      # {% nav site %} => <ul class="nav"><li class="on"><a href="/features">Features</a></li></ul>
      #
      class Nav < ::Liquid::Tag
        
        Syntax = /(#{::Liquid::Expression}+)?/
        
        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @site_or_page = $1 || 'page'
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'nav' - Valid syntax: nav <page|site>")
          end
              
          super
        end
        
        def render(context)
          @current_page = context.registers[:page]
          
          source = context.registers[@site_or_page.to_sym]
          
          # puts "[Nav] source = #{source.inspect}"
          
          if source.respond_to?(:name) # site ?
            source = source.pages.first # start from home page
          else
            source = source.parent
          end

          output = %{<ul id="nav">}
          output += source.children.map { |p| render_child_link(p) }.join("\n")
          output += %{</ul>}
          output
        end
        
        private
        
        def render_child_link(page)
          selected = @current_page._id == page._id ? ' on' : ''
          
          %{
            <li id="#{page.slug.dasherize}" class="link#{selected}">
              <a href="/#{page.fullpath}">#{page.title}</a>
            </li>
          }.strip
        end
        
        ::Liquid::Template.register_tag('nav', Nav)
      end
    end
  end
end