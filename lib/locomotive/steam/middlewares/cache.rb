module Locomotive
  module Steam
    module Middlewares

      class Cache

        attr_reader :app

        CACHEABLE_REQUEST_METHODS = %w(GET HEAD).freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          if cacheable?(env)
            fetch_cached_response(env)
          else
            app.call(env)
          end
        end

        private

        def fetch_cached_response(env)
          key = cache_key(env)

          if marshaled = Rails.cache.read(key)
            Marshal.load(marshaled)
          else
            app.call(env).tap do |response|
              Rails.cache.write(key, marshal(response))
            end
          end
        end

        def marshal(response)
          code, headers, body = response

          _headers = headers.dup.reject! { |key, val| key =~ /[^0-9A-Z_]/ || !val.respond_to?(:to_str) }

          Marshal.dump([code, _headers, body])
        end

        def cacheable?(env)
          CACHEABLE_REQUEST_METHODS.include?(env['REQUEST_METHOD']) &&
          !env['steam.live_editing'] &&
          env['steam.site'].try(:cache_enabled) &&
          env['steam.page'].try(:cache_enabled) &&
          is_redirect_url?(env['steam.page'], env['steam.locale'])
        end

        def cache_key(env)
          site, path, query = env['steam.site'], env['PATH_INFO'], env['QUERY_STRING']
          key = "#{Locomotive::VERSION}/site/#{site._id}/#{site.last_modified_at.to_i}/page/#{path}/#{query}"
          Digest::MD5.hexdigest(key)
        end

        def is_redirect_url?(page, locale)
          return false if page.nil?
          (page.try(:redirect_url) || {})[locale].blank?
        end

      end

    end
  end
end
