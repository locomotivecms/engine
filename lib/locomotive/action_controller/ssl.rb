module Locomotive
  module ActionController
    module Ssl

      def require_ssl
        # already a ssl request or ssl disabled ?
        return if !Locomotive.config.enable_admin_ssl || request.ssl?

        # only require ssl for requests for the main domain
        if !Locomotive.config.multi_sites? || Locomotive.config.multi_sites.domain == request.domain
          redirect_to protocol: 'https://'
        end

        true
      end

    end
  end
end

