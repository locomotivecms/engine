require 'rack/utils'

module Locomotive
  module Middlewares
    class Fonts
      include Rack::Utils

      def initialize(app, opts = {})
        @app = app
        @path_regexp = opts[:path] || %r{^/fonts/}
        @file_server = ::Rack::File.new(opts[:root] || "#{Rails.root}/public")
        @expires_in = opts[:expires_in] || 24.hour
      end

      def call(env)
        if env["PATH_INFO"] =~ @path_regexp
          site = fetch_site(env['SERVER_NAME'])

          if site.nil?
            @app.call(env)
          else
            env["PATH_INFO"] = ::File.join('/', 'sites', site.id.to_s, 'theme', env["PATH_INFO"])

            response = @file_server.call(env)

            response[1]['Cache-Control'] = "public; max-age=#{@expires_in}" # varnish

            response
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
