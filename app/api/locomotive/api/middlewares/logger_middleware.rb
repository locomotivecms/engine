module Locomotive
  module API
    module Middlewares

      class LoggerMiddleware

        def initialize(app)
          @app = app
        end

        def call(env)
          @app.call(env).tap do |response|
            log_message(response, env)
          end
        end

        private

        def log_message(response, env)
          message = payload(response, env).map { |p| "#{p.first}=\"#{p.last}\"" }.join(' ')

          Rails.logger.info(message)
        end

        def payload(response, env)
          params = env['api.endpoint'].params.to_hash
          params.delete_if { |k, _| %w(route_info format).include?(k) }

          [
            [:service,    'api.request'],
            [:method,     env['REQUEST_METHOD']],
            [:endpoint,   env['PATH_INFO']],
            [:params,     params.inspect],
            [:headers,    env.select { |k, v| k.start_with? 'HTTP_X' }],
            [:status,     response[0]],
            [:timestamp,  Time.zone.now]
          ]
        end

      end

    end
  end
end
