module Locomotive
  module Steam
    module Middlewares

      class WysihtmlCss

        GOOGLE_AMP_PATH = '_amp'

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          status, headers, response = @app.call(env)

          if content?(env['steam.page'], env['steam.path'], response)
            url   = ::ActionController::Base.helpers.stylesheet_path('locomotive/wysihtml5_editor')
            html  = %(<link rel="stylesheet" type="text/css" href="#{url}">)
            response.first.gsub!('</head>', %(#{html}</head>))
          end

          [status, headers, response]
        end

        protected

        def content?(page, path, response)
          !path.starts_with?(GOOGLE_AMP_PATH + '/') &&
          !page.redirect &&
          page.response_type == 'text/html' &&
          response.first
        end

      end
    end
  end
end
