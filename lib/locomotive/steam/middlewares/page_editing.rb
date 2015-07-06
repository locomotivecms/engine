module Locomotive
  module Steam
    module Middlewares

      class PageEditing

        include Locomotive::Engine.routes.url_helpers

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          status, headers, response = @app.call(env)
          site, page, locale = env['steam.site'], env['steam.page'], env['steam.locale'].to_s

          if page && !page.redirect && page.response_type == 'text/html' && response.first
            html = %(
              <meta name="locomotive-locale" content="#{locale}" />
              <meta name="locomotive-editable-elements-path" content="#{editable_elements_path(site, page, locale, env)}" />
              <meta name="locomotive-page-id" content="#{page._id}" />
            )
            response.first.gsub!('</head>', %(#{html}</head>))
          end

          [status, headers, response]
        end

        def editable_elements_path(site, page, locale, env)
          options = {}

          if content_entry_id = env['steam.content_entry'].try(:_id)
            options = {
              content_entry_id: content_entry_id,
              preview_path:     env['steam.path'],
            }
          end

          options[:content_locale] = locale if site.locales.size > 1

          super(site, page._id, options)
        end

      end

    end
  end
end
