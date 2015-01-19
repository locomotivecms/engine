module Locomotive
  module Middlewares
    class Site

      def initialize(app, opts = {})
        @app    = app
      end

      def call(env)
        env['locomotive.site'] = fetch_site(env)
        @app.call(env)
      end

      def fetch_site(env)
        request = Rack::Request.new(env)
        handle  = site_handle(request)

        Locomotive.log "[fetch site] host = #{request.host} / site_handle = #{handle.inspect}"

        if handle
          Locomotive::Site.where(handle: handle).first
        else
          Locomotive::Site.match_domain(request.host).first
        end
      end

      def site_handle(request)
        
        if handle = request.env['HTTP_X_LOCOMOTIVE_SITE_HANDLE']
          return handle
        elsif request.path_info =~ site_handle_regexp
          return $1 if !Locomotive.config.reserved_site_handles.include?($1)
        end

        nil
      end

      def site_handle_regexp
        @regexp ||= /#{Locomotive.mounted_on}\/([^\/]+)/o
      end

    end
  end
end
