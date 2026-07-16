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

          headers = env.select { |k, _| k.is_a?(String) && k.start_with?('HTTP_X') }

          [
            [:service,    'api.request'],
            [:method,     env['REQUEST_METHOD']],
            [:endpoint,   env['PATH_INFO']],
            [:params,     parameter_filter.filter(params).inspect],
            [:headers,    parameter_filter.filter(headers)],
            [:status,     response[0]],
            [:timestamp,  Time.zone.now]
          ]
        end

        # Build after initialization so host application filters are included.
        def parameter_filter
          @parameter_filter ||= ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
        end

      end

    end
  end
end
