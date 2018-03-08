module Locomotive
  module Concerns
    module RedirectToMainHostController

      extend ActiveSupport::Concern

      included do

        before_action :redirect_to_main_host

      end

      private

      def redirect_to_main_host
        return if Locomotive.config.host.blank? || request.env['locomotive.default_host'].present?

        if request.host != Locomotive.config.host
          options = { host: Locomotive.config.host }
          options[:port] = request.port if request.port != 80

          redirect_to root_url(options)
        end
      end

    end
  end
end
