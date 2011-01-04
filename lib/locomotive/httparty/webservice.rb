module Locomotive
  module Httparty
    class Webservice

      include ::HTTParty

      def self.consume(url, options = {})
        url = HTTParty.normalize_base_uri(url)

        options[:base_uri], path = url.scan(/^(http[s]?:\/\/.+\.[a-z]{2,})(\/.+)*/).first
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
