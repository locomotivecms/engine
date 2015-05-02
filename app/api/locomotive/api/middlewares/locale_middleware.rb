module Locomotive
  module API
    module Middlewares

      class LocaleMiddleware

        def initialize(app)
          @app = app
        end

        # Rules (order is important):
        #
        # 1. check for the X-Locomotive-Locale header
        # 2. check for the locale request param
        # 3. check for the site default locale
        # 4. if none, take the default locomotive locale
        #
        def call(env)
          locale = find_locale(env)
          ::Mongoid::Fields::I18n.with_locale(locale) do
            @app.call(env)
          end
        end

        private

        def find_locale(env)
          env['HTTP_X_LOCOMOTIVE_LOCALE'] ||
          Rack::Request.new(env).params[:locale] ||
          env['locomotive.site'].try(:default_locale) ||
          Locomotive.config.site_locales.first
        end

      end

    end
  end
end
