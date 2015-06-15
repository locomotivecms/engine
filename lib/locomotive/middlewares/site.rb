module Locomotive
  module Middlewares
    class Site

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        env['locomotive.site'] = env['steam.site'] = fetch_site(env)
        @app.call(env)
      end

      def fetch_site(env)
        request = Rack::Request.new(env)
        handle  = site_handle(request)

        return nil if handle == 'api'

        Locomotive.log "[fetch site] host = #{request.host} / site_handle = #{handle.inspect}"

        if handle
          # The site is not rendered from a domain but from the back-office
          # we need to get:
          # - the path of "mouting point" (basically: locomotive/:handle/preview)
          # - the real path of the page
          #
          # FIXME: move that in a different middleware
          mounted_on = "#{Locomotive.mounted_on}/#{handle}/preview"

          env['locomotive.mounted_on']  = env['steam.mounted_on'] = mounted_on
          env['locomotive.path']        = request.path_info.gsub(mounted_on, '')

          env['steam.live_editing']     = true

          Locomotive::Site.where(handle: handle).first
        else
          env['locomotive.path'] = request.path_info

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
