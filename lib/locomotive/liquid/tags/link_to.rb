module Locomotive
  module Liquid
    module Tags
      class LinkTo < Hybrid

        Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

        include UrlHelper
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
          render_url(context) do |page, url|
            label = label_from_page(page)

            if @render_as_block
              context.scopes.last['target'] = page
              label = super.html_safe
            end

            link_to label, url
          end

        end

        protected

        def label_from_page(page)
          ::Mongoid::Fields::I18n.with_locale(@options['locale']) do
            if page.templatized?
              page.content_entry._label
            else
              page.title
            end
          end
        end

      end

      ::Liquid::Template.register_tag('link_to', LinkTo)
    end
  end
end
