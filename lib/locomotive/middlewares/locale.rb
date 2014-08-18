module Locomotive
  module Middlewares
    class Locale

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        env['locomotive.locale'] = retrieve_locale(env)          
        @app.call(env)
      end

      def retrieve_locale(env)
        site = env['locomotive.site']
        $1 if site.try(:localized?) && env['PATH_INFO'] =~ %r(^/(#{site.locales.join('|')}))          
      end
 
    end
  end
end