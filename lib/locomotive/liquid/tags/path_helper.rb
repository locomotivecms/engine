module Locomotive
  module Liquid
    module Tags
      module PathHelper

        Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @handle = $1
            @options = {}
            markup.scan(::Liquid::TagAttributes) do |key, value|
              @options[key] = value
            end
          else
            self.wrong_syntax!
          end

          super
        end

        def render_path(context, &block)
          site  = context.registers[:site]

          if page = self.retrieve_page_from_handle(site, context)
            path = self.public_page_fullpath(site, page)

            if block_given?
              block.call page, path
            else
              path
            end
          else
            '' # no page found
          end
        end

        protected

        def retrieve_page_from_handle(site, context)
          handle = context[@handle] || @handle

          case handle
          when Locomotive::Page                         then handle
          when Locomotive::Liquid::Drops::Page          then handle.instance_variable_get(:@_source)
          when String                                   then fetch_page(site, handle)
          when Locomotive::ContentEntry                 then fetch_page(site, handle, true)
          when Locomotive::Liquid::Drops::ContentEntry  then fetch_page(site, handle.instance_variable_get(:@_source), true)
          else
            nil
          end
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

        def public_page_fullpath(site, page)
          fullpath = site.localized_page_fullpath(page, @options['locale'])

          if page.templatized?
            fullpath.gsub!('content_type_template', page.content_entry._slug)
          end

          File.join('/', fullpath)
        end


      end
    end
  end
end
