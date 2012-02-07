require 'rack/cache'

module Locomotive
  module Middlewares
    class Cache

      def initialize(app, opts = {}, &block)
        url_format  = Locomotive::Dragonfly.app.configuration[:url_format]
        base_format = url_format.split('/:').first rescue '/images/dynamic'

        @app      = app
        @regexp   = %r{^#{base_format}/}
        @context  = ::Rack::Cache.new(app, opts, &block)
      end

      def call(env)
        if env['PATH_INFO'] =~ @regexp
          @context.call(env)
        else
          @app.call(env)
        end
      end

    end

  end
end
