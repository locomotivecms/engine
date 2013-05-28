module Locomotive
  module ActionController
    module Ssl

      def require_ssl
        redirect_to protocol: 'https://' if Locomotive.config.enable_admin_ssl && !request.ssl?
      end

    end
  end
end