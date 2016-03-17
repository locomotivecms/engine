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
          setup_i18n_fallback(env['locomotive.site'])
          ::Mongoid::Fields::I18n.with_locale(locale) do
            @app.call(env)
          end
        end

        private

        def find_locale(env)
          env['HTTP_X_LOCOMOTIVE_LOCALE'].presence ||
          params(env)[:locale].presence ||
          params(env)['locale'].presence ||
          env['locomotive.site'].try(:default_locale).presence ||
          Locomotive.config.site_locales.first
        end

        def setup_i18n_fallback(site)
          ::Mongoid::Fields::I18n.clear_fallbacks
          (site.try(:locales) || []).each do |locale|
            ::Mongoid::Fields::I18n.fallbacks_for(locale, site.locale_fallbacks(locale))
          end
        end

        def params(env)
          @params ||= Rack::Request.new(env).params
        end

      end

    end
  end
end
