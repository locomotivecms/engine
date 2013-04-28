module Locomotive
  module Middlewares
    class Permalink

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] =~ /^#{Locomotive.mounted_on}\/_permalink.json/
          request     = Rack::Request.new(env)
          underscore  = request.params['underscore'] == '1'
          value       = request.params['string'].try(:permalink, underscore)

          [200, {}, [{ value: value }.to_json]]
        else
          @app.call(env)
        end
      end
    end
  end
end