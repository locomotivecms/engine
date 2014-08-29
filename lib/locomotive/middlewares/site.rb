module Locomotive
  module Middlewares
    class Site

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        env['locomotive.site'] = fetch_site(env)
        @app.call(env)
      end

      def fetch_site(env)
        request = Rack::Request.new(env)
        Locomotive.log "[fetch site] host = #{request.host} / #{env['HTTP_HOST']}"
        if Locomotive.config.multi_sites?
          Locomotive::Site.match_domain(request.host).first
        else
          Locomotive::Site.first
        end
      end

    end
  end
end