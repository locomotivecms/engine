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
          site  = context.registers[:site]

          if page = self.retrieve_page_from_handle(site, context)
            label = self.label_from_page(page)
            path  = self.public_page_url(site, page)

            if @render_as_block
              context.scopes.last['target'] = page
              label = super.html_safe
            end

            link_to label, path
          else
            '' # no page found
          end
        end

        protected

        def retrieve_page_from_handle(site, context)
          context.scopes.reverse_each do |scope|
            handle = scope[@handle] || @handle

            page = case handle
            when Locomotive::Page         then handle
            when String                   then fetch_page(site, handle)
            when Locomotive::ContentEntry then fetch_page(site, handle, true)
            else
              nil
            end

            return page unless page.nil?
          end

          nil
        end

        def fetch_page(site, handle, templatized = false)
          ::Mongoid::Fields::I18n.with_locale(@options['locale']) do
            if templatized
              criteria = site.pages.where(target_klass_name: handle.class.to_s, templatized: true)
              criteria = criteria.where(handle: @options['with']) if @options['with']
              criteria.first.tap do |page|
                page.content_entry = handle if page
              end
            else
              site.pages.where(handle: handle).first
            end
          end
        end

        def label_from_page(page)
          ::Mongoid::Fields::I18n.with_locale(@options['locale']) do
            if page.templatized?
              page.content_entry._label
            else
              page.title
            end
          end
        end

        def public_page_url(site, page)
          fullpath = site.localized_page_fullpath(page, @options['locale'])

          if page.templatized?
            fullpath.gsub!('content_type_template', page.content_entry._slug)
          end

          File.join('/', fullpath)
        end

      end

      ::Liquid::Template.register_tag('link_to', LinkTo)
    end
  end
end
