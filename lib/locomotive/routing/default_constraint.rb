module Locomotive
  module Routing
    class DefaultConstraint

      def self.matches?(request)
        if Locomotive.config.multi_sites?
          domain, subdomain = domain_and_subdomain(request)
          subdomain = 'www' if subdomain.blank?

          domain == Locomotive.config.domain && Locomotive.config.reserved_subdomains.include?(subdomain)
        else
          false
        end
      end

      # see actionpack/lib/action_dispatch/http/url.rb for more information
      def self.domain_and_subdomain(request)
        [extract_domain(request), extract_subdomain(request)]
      end

      def self.extract_domain(request, tld_length = 1)
        return nil unless named_host?(request.host)
        request.host.split('.').last(1 + tld_length).join('.')
      end

      def self.extract_subdomain(request, tld_length = 1)
        subdomains(request, tld_length).join('.')
      end

      def self.named_host?(host)
        !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
      end

      def self.subdomains(request, tld_length = 1)
        return [] unless named_host?(request.host)
        parts = request.host.split('.')
        parts[0..-(tld_length+2)]
      end

    end
  end
end
