module Locomotive
  module Middlewares
    class SeoTrailingSlash

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        path, query = env['PATH_INFO'], env['QUERY_STRING']

        if !path.starts_with?("#{Locomotive.mounted_on}/") && (match = path.match(%r{(.+)/$}))
          url = self.redirect_url(match[1], query)
          self.redirect_to(url)
        else
          @app.call(env)
        end
      end

      protected

      # Create a 301 response and set it up accordingly.
      #
      # @params [ String ] url The url for the redirection
      #
      # @return [ Array ] It has the 3 parameters (status, header, body)
      #
      def redirect_to(url)
        response = Rack::Response.new
        response.redirect(url, 301) # moved permanently
        response.finish
        response.to_a
      end

      def redirect_url(base, query)
        if query.blank?
          base
        else
          "#{base}?#{query}"
        end
      end

    end
  end
end