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

        self.get(path, options).try(:underscore_keys)
      end

    end
  end
end
