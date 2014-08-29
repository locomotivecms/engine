module Locomotive
  module Middlewares
    class Base

      protected

      def is_backoffice?(request)
        request.path.match(%r(^#{Locomotive.mounted_on}(/|$))) != nil
      end

      def is_assets?(request)
        request.path.match(%r(^/assets(/|$))) != nil
      end

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

      # Modify the fullpath according to the regexp/replacement
      # and return the updated url
      #
      # @params [ Rack::Request ] request The base request
      # @params [ Regexp ] regexp The regexp to apply to the fullpath
      # @params [ String ] replacement The replacement string for the fullpath 
      #
      # @return [ String ] The updated url
      #
      def modify_url(request, path)
        url = "#{request.base_url}#{path}"
        url += "?#{request.query_string}" unless request.query_string.empty?          
        url
      end

    end
  end
end