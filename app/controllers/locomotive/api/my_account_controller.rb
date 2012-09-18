module Locomotive
  module Api
    class MyAccountController < BaseController

      skip_load_and_authorize_resource

      # FIXME: the auto-loaded site won't pass authorization for show, update, or destroy
      # skip_load_and_authorize_resource :only => [ :show, :update, :destroy ]

      def show
        respond_with(current_locomotive_account)
      end

    end

  end
end

