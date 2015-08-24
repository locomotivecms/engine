module Locomotive
  module Middlewares
    class Site

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        env['locomotive.site'] = env['steam.site'] = fetch_site(env)
        begin
          @app.call(env)
        rescue ::Locomotive::Steam::NoSiteException => exception
          # no_site!
          Locomotive::ErrorsController.action(:no_site).call(env)
        end
      end

      private

      def fetch_site(env)
        request = Rack::Request.new(env)
        handle  = site_handle(request)

        return nil if handle == 'api'

        Locomotive.log "[fetch site] host = #{request.host} / site_handle = #{handle.inspect}"

        if handle
          fetch_from_handle(handle, env, request)
        elsif !request_for_the_back_office_and_default_host?(request)
          fetch_from_host(env, request)
        else
          nil
        end
      end

      # def no_site!(env)
      #   Locomotive::ErrorsController.action(:no_site).call(env)
      #   # [200, { 'Content-Type' => 'text/html' }, ['Hello world']]
      # end

      # The site is not rendered from a domain but from the back-office
      # we need to get:
      # - the path of "mouting point" (basically: locomotive/:handle/preview)
      # - the real path of the page
      #
      # FIXME: move that in a different middleware
      def fetch_from_handle(handle, env, request)
        mounted_on = "#{Locomotive.mounted_on}/#{handle}/preview"

        env['locomotive.mounted_on']  = env['steam.mounted_on'] = mounted_on
        env['locomotive.path']        = request.path_info.gsub(mounted_on, '')

        env['steam.live_editing']     = true

        Locomotive::Site.where(handle: handle).first
      end

      # The request is for one of the domains registered in Locomotive.
      # Find the related site.
      def fetch_from_host(env, request)
        env['locomotive.path'] = request.path_info
        Locomotive::Site.match_domain(request.host).first
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

      # Is it a request for the back-office AND the domain used to also
      # render the site of the Rails application?
      def request_for_the_back_office_and_default_host?(request)
        default_host && request.host == default_host && request.path_info =~ /#{Locomotive.mounted_on}\//
      end

      def default_host
        Locomotive.config.host
      end

    end
  end
end
