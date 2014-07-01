module Locomotive
  module Liquid

    class AssetHost

      IsHTTP = /^https?\/\//o

      attr_reader :request, :site, :host

      def initialize(request, site, host)
        @request, @site = request, site

        @host = build_host(host, request, site)
      end

      def compute(source, timestamp = nil)
        return source if source.nil?

        return add_timestamp_suffix(source, timestamp) if source =~ IsHTTP

        url = self.host ? URI.join(host, source).to_s : source

        add_timestamp_suffix(url, timestamp)
      end

      private

      def build_host(host, request, site)
        if host
          if host.respond_to?(:call)
            host.call(request, site)
          else
            host
          end
        else
          nil
        end
      end

      def add_timestamp_suffix(source, timestamp)
        if timestamp.nil? || timestamp == 0 || source.include?('?')
          source
        else
          "#{source}?#{timestamp}"
        end
      end

    end

  end
end