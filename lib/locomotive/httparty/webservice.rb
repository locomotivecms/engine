require 'uri'

module Locomotive
  module Httparty
    class Webservice

      include ::HTTParty

      def self.consume(url, options = {})
        options[:method] = :get if options[:method].nil?

        options.delete(:format) if options[:format] == 'default'

        path = extract_path(url, options)

        # auth ?
        username, password = options.delete(:username), options.delete(:password)
        options[:basic_auth] = { username: username, password: password } if username

        self.perform_request_to(path, options)
      end

      def self.extract_path(url, options)
        url     = HTTParty.normalize_base_uri(url)
        uri     = URI.parse(url)
        params  = Rack::Utils.parse_nested_query(uri.query)

        key = options[:method].to_sym == :post ? :body : :query
        options[key] = params unless params.blank?

        (uri.path.blank? ? '/' : uri.path).tap do
          uri.query = nil; uri.path = ''
          options[:base_uri] = uri.to_s
        end
      end

      def self.perform_request_to(path, options)
        # [DEBUG]
        # puts "[WebService] consuming #{path}, #{options.inspect}"

        # sanitize the options
        options[:format]  = options[:format].gsub(/[\'\"]/, '').to_sym if options.has_key?(:format)
        options[:headers] = { 'User-Agent' => 'LocomotiveCMS' } if options[:with_user_agent]

        response        = self.send(options.delete(:method), path, options)
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
