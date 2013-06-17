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
          page, link, entry = templatized_page(site, context, @options) || page(site, @handle, @options['locale'])
          path = public_page_url(site, page, locale: @options['locale'], content: entry)
          
          if @render_as_block
            context.scopes.last['target'] = page
            link_to super.html_safe, path
          else
            link_to link, path
          end
        end
        
        protected
        def templatized_page(site, context, options)
          ::Mongoid::Fields::I18n.with_locale(options['locale']) do
            context.scopes.reverse_each do |scope|
              if scope[@handle].is_a?(Locomotive::ContentEntry)
                entry = scope[@handle]
                criteria = site.pages.where(target_klass_name: entry.class.to_s, templatized: true)
                criteria = criteria.where(handle: options['with']) if options['with']
                page = criteria.first
                return [page, entry._label, entry]
              end
            end
          end
          return false
        end
        
        def page(site, handle, locale = nil)
          ::Mongoid::Fields::I18n.with_locale(locale) do
            page = site.pages.where(handle: @handle).first
            return [page, page.title]
          end
        end
        
        def public_page_url(site, page, options = {})
          locale    = options[:locale]
          fullpath  = site.localized_page_fullpath(page, locale)

          if content = options.delete(:content)
            fullpath = File.join(fullpath.gsub('content_type_template', ''), content._slug)
          end

          File.join('/', fullpath)
        end
      end

      ::Liquid::Template.register_tag('link_to', LinkTo)
    end
  end
end
