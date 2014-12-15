module Locomotive
  module Api
    class VersionController < BaseController

      skip_before_filter :require_account, :require_site, :validate_site_membership

      def show
        respond_with({ engine: Locomotive::VERSION })
      end

    end
  end
end
