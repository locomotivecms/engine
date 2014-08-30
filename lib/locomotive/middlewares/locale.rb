module Locomotive
  module Middlewares
    class Locale

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        retrieve_and_set_locale(env)
        @app.call(env)
      end

      def retrieve_and_set_locale(env)
        site = env['locomotive.site']

        if site.try(:localized?)
          if env['PATH_INFO'] =~ %r{^/(#{site.locales.join('|')})+(\/|$)}
            locale  = $1
            path    = env['PATH_INFO'].gsub($1 + $2, '').gsub(/(\/_edit|\/_admin)$/, '')

            Locomotive.log "[extract locale] locale = #{locale} / #{path}"

            env['locomotive.locale']  = locale
            env['locomotive.path']    = path
          end
        end
      end

    end
  end
end