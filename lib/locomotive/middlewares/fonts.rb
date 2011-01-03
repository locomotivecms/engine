module Locomotive
  module Middlewares
    class Fonts

      def initialize(app, opts = {})
        @app = app
        @path_regexp = opts[:path] || %r{^/fonts/}
        @expires_in = opts[:expires_in] || 24.hour # varnish
      end

      def call(env)
        if env["PATH_INFO"] =~ @path_regexp
          site = fetch_site(env['SERVER_NAME'])

          if site.nil?
            @app.call(env)
          else
            body = ThemeAssetUploader.build(site, env["PATH_INFO"]).read.to_s

            [200, { 'Cache-Control' => "public; max-age=#{@expires_in}" }, [body]]
          end
        else
          @app.call(env)
        end
      end

      protected

      def fetch_site(domain_name)
        Rails.cache.fetch(domain_name, :expires_in => @expires_in) do
          Site.match_domain(domain_name).first
        end
      end
    end
  end
end
