module Locomotive
  module Liquid
    module Tags
      class LinkTo < Hybrid
        Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/
        
        include ActionView::Helpers::UrlHelper
        
        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @handle = $1
            @options = {}
            markup.scan(::Liquid::TagAttributes) do |key, value|
              @options[key] = value
            end
          else
            raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: link_to page_handle, locale es (locale is optional)")
          end
          
          super
        end
        
        def render(context)
          site = context.registers[:site]
          if page = site.pages.where(handle: @handle).first
            path = "/#{site.localized_page_fullpath(page, @options['locale'])}"
            ::Mongoid::Fields::I18n.with_locale(@options['locale']) do
              if @render_as_block
                context.scopes.last['target'] = page
                link_to super.html_safe, path
              else
                link_to page.title, path
              end
            end
          end
        end
      end

      ::Liquid::Template.register_tag('link_to', LinkTo)
    end
  end
end
