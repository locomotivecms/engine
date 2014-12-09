module Locomotive
  module Middlewares
    class LocaleRedirection < Base

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        if url = redirect_url(env)
          redirect_to url
        else
          @app.call(env)
        end
      end

      protected

      def redirect_url(env)
        request = Rack::Request.new(env)

        site, locale = env['locomotive.site'], env['locomotive.locale']

        if apply_redirection?(site, request)
          segments = request.path.split '/'

          if !locale && site.prefix_default_locale
            # force locale in path by redirecting
            segments.insert(1, "#{site.default_locale}")
            modify_url(request, segments.join('/'))

          elsif locale == site.default_locale && !site.prefix_default_locale
            # strip locale
            segments.delete_at(1)
            modify_url(request, segments.join('/'))
          end
        end
      end

      def apply_redirection?(site, request)
        site.try(:localized?) && request.get? && !is_backoffice?(request) && !is_assets?(request)
      end

    end
  end
end