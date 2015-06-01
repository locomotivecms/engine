module Locomotive
  module Middlewares
    class PageEditing

      include Locomotive::Engine.routes.url_helpers

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)
        site, page = env['steam.site'], env['steam.page']

        if page && page.response_type == 'text/html'
          html = %(
            <meta name="locomotive-editable-elements-path" content="#{editable_elements_path(site, page._id)}" />
            <meta name="locomotive-page-id" content="#{page._id}" />
          )
          response.first.gsub!('</head>', %(#{html}</head>))
        end

        [status, headers, response]
      end
    end
  end
end
