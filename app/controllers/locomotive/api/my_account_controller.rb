module Locomotive
  module Api
    class MyAccountController < BaseController

      skip_load_and_authorize_resource

      skip_before_filter :require_site, :set_locale, :set_current_thread_variables

      def show
        respond_with(current_locomotive_account)
      end

    end

  end
end

