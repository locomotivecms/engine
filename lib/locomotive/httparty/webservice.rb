require 'uri'

module Locomotive
  module Httparty
    class Webservice

      include ::HTTParty

      def self.consume(url, options = {})
        options[:base_uri], path = self.extract_base_uri_and_path(url)

        options.delete(:format) if options[:format] == 'default'

        # auth ?
        username, password = options.delete(:username), options.delete(:password)
        options[:basic_auth] = { username: username, password: password } if username

        self.perform_request_to(path, options)
      end

      def self.extract_base_uri_and_path(url)
        url = HTTParty.normalize_base_uri(url)

        uri       = URI.parse(url)
        path      = uri.request_uri || '/'
        base_uri  = "#{uri.scheme}://#{uri.host}"
        base_uri  += ":#{uri.port}" if uri.port != 80

        [base_uri, path]
      end

      def self.perform_request_to(path, options)
        # [DEBUG] puts "[WebService] consuming #{path}, #{options.inspect}"

        response        = self.get(path, options)
        parsed_response = response.parsed_response

        if response.code == 200
          if parsed_response.respond_to?(:underscore_keys)
            parsed_response.underscore_keys
          else
            parsed_response.collect(&:underscore_keys)
          end
        else
          nil
        end
      end

    end
  end
end