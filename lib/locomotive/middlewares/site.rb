module Locomotive
  module Middlewares
    class Site

      include Locomotive::Engine.routes.url_helpers

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        # do not process "/assets"
        # only in dev, since the assets are precompiled in production
        if request_for_the_back_office_assets?(request)
          @app.call(env)
        else
          env['locomotive.site'] = site = fetch_site(request)

          # deal with the Steam entity instead of a Mongoid document
          env['steam.site'] = site.try(:to_steam)
          env['steam.is_default_host'] = default_host?(request)

          begin
            @app.call(env)
          rescue ::Locomotive::Steam::NoSiteException => exception
            handle_no_account_or_site(env, request)
          end
        end
      end

      private

      def fetch_site(request)
        handle  = site_handle(request)

        return nil if handle == 'api'

        Locomotive.log "[fetch site] host = #{request.host} / site_handle = #{handle.inspect} / locale = #{::Mongoid::Fields::I18n.locale.inspect}"

        if handle
          fetch_from_handle(handle, request)
        elsif !request_for_the_back_office_and_default_host?(request)
          fetch_from_host(request)
        else
          nil
        end
      end

      # if no account in the database, must be a fresh install,
      # then ask the user to create the first account.
      # if accounts but no site, redirect to the sign in page
      def handle_no_account_or_site(env, request)
        if Locomotive::Account.count == 0
          redirect_to((Locomotive.config.enable_registration ? sign_up_path : sign_in_path))
        elsif default_host?(request)
          redirect_to(sign_in_path)
        else
          Locomotive::ErrorsController.action(:no_site).call(env)
        end
      end

      # The site is not rendered from a domain but from the back-office
      # we need to get:
      # - the path of "mouting point" (basically: locomotive/:handle/preview)
      # - the real path of the page
      #
      # FIXME: move that in a different middleware
      def fetch_from_handle(handle, request)
        mounted_on  = "#{Locomotive.mounted_on}/#{handle}/preview"
        logged_in   = request.env['warden'].try(:user).present?

        request.env['locomotive.mounted_on']  = request.env['steam.mounted_on'] = mounted_on
        request.env['locomotive.path']        = request.path_info.gsub(mounted_on, '')

        request.env['steam.live_editing']     = logged_in

        request.env['steam.private_access_disabled'] = logged_in

        Locomotive::Site.where(handle: handle).first
      end

      # The request is for one of the domains registered in Locomotive.
      # Find the related site.
      def fetch_from_host(request)
        request.env['locomotive.path'] = request.path_info
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

      def redirect_to(destination)
        [301, { 'Location' => destination, 'Content-Type' => 'text/html' }, []]
      end

      def site_handle_regexp
        @regexp ||= /#{Locomotive.mounted_on}\/([^\/]+)/o
      end

      def request_for_the_back_office_assets?(request)
        default_host?(request) && request.path_info.starts_with?('/assets/')
      end

      # Is it a request for the back-office AND the domain used to also
      # render the site of the Rails application?
      def request_for_the_back_office_and_default_host?(request)
        default_host?(request) && request.path_info =~ /#{Locomotive.mounted_on}\//
      end

      def default_host?(request)
        (default_host && request.host == default_host) || localhost?(request)
      end

      def localhost?(request)
        request.host == '0.0.0.0' || request.host == 'localhost'
      end

      def default_host
        Locomotive.config.host
      end

    end
  end
end
