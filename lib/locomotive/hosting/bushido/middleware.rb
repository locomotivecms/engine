require 'rack/utils'

module Locomotive
  module Hosting
    module Bushido
      class Middleware

        # BUSHIDO_JS_URL = 'http://localhost:4567/javascripts/bushido.js'
        BUSHIDO_JS_URL = 'http://bushi.do/api/bushido.js'

        include Rack::Utils

        def initialize(app, opts = {})
          @app = app
          @bushido_app_name       = ENV['BUSHIDO_APP']
          @bushido_metrics_token  = ENV['BUSHIDO_METRICS_TOKEN']
          @bushido_claimed        = ::Locomotive.bushido_app_claimed?
        end

        def call(env)
          status, headers, response = @app.call(env)

          content = ""
          response.each { |part| content += part }

          # "claiming" bar + stats ?
          content.gsub!(/<\/body>/i, <<-STR
              <script type="text/javascript">
                var _bushido_app = '#{@bushido_app_name}';
                var _bushido_claimed = #{@bushido_claimed.to_s};
                var _bushido_metrics_token = '#{@bushido_metrics_token}';
                (function() {
                  var bushido = document.createElement('script'); bushido.type = 'text/javascript'; bushido.async = true;
                  bushido.src = '#{BUSHIDO_JS_URL}?#{::Bushido::VERSION.gsub('.', '')}';
                  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(bushido, s);
                })();
              </script>
            </body>
          STR
          )

          headers['content-length'] = bytesize(content).to_s

          [status, headers, [content]]
        end

      end
    end
  end
end
