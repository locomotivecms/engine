module Locomotive
  module ActionController
    module Ssl

      def require_ssl
        # already a ssl request or ssl disabled ?
        return if !Locomotive.config.enable_admin_ssl || request.ssl?

        redirect_to protocol: 'https://'
      end

    end
  end
end

