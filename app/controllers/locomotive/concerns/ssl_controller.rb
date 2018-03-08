module Locomotive
  module Concerns
    module SslController

      extend ActiveSupport::Concern

      included do

        before_action :require_ssl

      end

      private

      def require_ssl
        # already a ssl request or ssl disabled ?
        return if !Locomotive.config.enable_admin_ssl || request.ssl?

        redirect_to protocol: 'https://'
      end

    end
  end
end
