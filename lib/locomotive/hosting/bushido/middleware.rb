require 'rack/utils'

module Locomotive
  module Hosting
    module Bushido
      class Middleware

        include Rack::Utils

        def initialize(app, opts = {})
          @app = app
          @path_regexp = %r{^/admin/}
        end

        def call(env)
          if env['PATH_INFO'] =~ @path_regexp
            status, headers, response = @app.call(env)

            content = ""
            response.each { |part| content += part }

            # enable chat
            content.gsub!(/<\/head>/i, <<-STR
                <script type="text/javascript">var _bushido_chat = true;</script>
              </head>
            STR
            )

            headers['content-length'] = bytesize(content).to_s

            [status, headers, [content]]
          else
            @app.call(env)
          end
        end

      end
    end
  end
end
