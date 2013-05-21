module Locomotive
  module Liquid
    module Tags
      class LinkTo < ::Liquid::Tag
        Syntax = /(#{::Liquid::Expression}+)?/
        
        include ActionView::Helpers::UrlHelper
        
        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @handle = $1
          else
            raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: link_to [page_handle]")
          end
          
          super
        end
        
        def render(context)
          site = context.registers[:site]
          if page = site.pages.where(handle: @handle).first
            link_to page.title, "/#{site.localized_page_fullpath(page)}"
          end
        end
      end

      ::Liquid::Template.register_tag('link_to', LinkTo)
      
      class LinkToBlock < ::Liquid::Block
        Syntax = LinkTo::Syntax
        
        include ActionView::Helpers::UrlHelper
        
        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @handle = $1
          else
            raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: link_to [page_handle]")
          end
          
          super
        end
        
        def render(context)
          site = context.registers[:site]
          if page = site.pages.where(handle: @handle).first
            context.scopes.last['linked'] = page.title
            link_to super.html_safe, "/#{site.localized_page_fullpath(page)}"
          end
        end
      end

      ::Liquid::Template.register_tag('link_to_block', LinkToBlock)
    end
  end
end
