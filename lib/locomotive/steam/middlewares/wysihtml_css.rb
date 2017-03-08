module Locomotive
  module Steam
    module Middlewares

      class WysihtmlCss

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          status, headers, response = @app.call(env)

          if env['steam.live_editing'] && content?(env['steam.page'], response)
            url   = ::ActionController::Base.helpers.stylesheet_url('locomotive/wysihtml5_editor')
            html  = %(<link rel="stylesheet" type="text/css" href="#{url}">)
            response.first.gsub!('</head>', %(#{html}</head>))
          end

          [status, headers, response]
        end

        protected

        def content?(page, response)
          page && !page.redirect && page.response_type == 'text/html' && response.first
        end

      end
    end
  end
end
