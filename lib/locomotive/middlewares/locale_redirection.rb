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
        if site.try(:localized?) and request.get? and !is_backoffice?(request) and !is_assets?(request)
          components = request.path.split '/'
          if !locale && site.prefix_default_locale
            # force locale in path by redirecting
            components.insert(1, "#{site.default_locale}")
            modify_url(request, components.join('/'))
          elsif locale == site.default_locale && !site.prefix_default_locale
            # strip locale
            components.delete_at(1)
            modify_url(request, components.join('/'))
          end
        end
      end
 
    end
  end
end