module Locomotive
  module Steam
    module Middlewares

      class Cache

        attr_reader :app

        def initialize(app)
          @app = app
        end

        def call(env)
          site, page, path, live_editing = env['steam.site'], env['steam.page'], env['steam.path'], env['steam.live_editing']

          if cache_enabled?(site, page, live_editing)
            fetch_cached_response(site, path, env)
          else
            app.call(env)
          end
        end

        private

        def fetch_cached_response(site, path, env)
          key = cache_key(site, path)

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

          _headers = headers.dup.delete_if { |name, _| name.include?('.') }

          Marshal.dump([code, _headers, body])
        end

        def cache_enabled?(site, page, live_editing)
          !live_editing && site.try(:cache_enabled) && page.try(:cache_enabled)
        end

        def cache_key(site, path)
          "site/#{site._id}/#{site.template_version.to_i}/#{site.content_version.to_i}/page/#{path}"
        end

      end

    end
  end
end
