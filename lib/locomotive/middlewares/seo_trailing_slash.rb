module Locomotive
  module Middlewares
    class SeoTrailingSlash < Base

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        path = request.path

        if !is_backoffice?(request) && path.size > 1 && path.ends_with?('/')
          url = modify_url(request, request.path.chop)
          redirect_to(url)
        else
          @app.call(env)
        end
      end

    end
  end
end