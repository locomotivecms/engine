require 'uri'

module Locomotive
  module Httparty
    class Webservice

      include ::HTTParty

      def self.consume(url, options = {})
        url = HTTParty.normalize_base_uri(url)

        uri = URI.parse(url)
        options[:base_uri] = "#{uri.scheme}://#{uri.host}"
        options[:base_uri] += ":#{uri.port}" if uri.port != 80
        path = uri.request_uri

        options.delete(:format) if options[:format] == 'default'

        username, password = options.delete(:username), options.delete(:password)
        options[:basic_auth] = { :username => username, :password => password } if username

        path ||= '/'

        # puts "[WebService] consuming #{path}, #{options.inspect}"

        response = self.get(path, options)

        if response.code == 200
          if response.respond_to?(:underscore_keys)
            response.underscore_keys
          else
            response.collect(&:underscore_keys)
          end
        else
          nil
        end

      end

    end
  end
end
