module Locomotive
  module Devise

    class FailureApp < ::Devise::FailureApp

      include ::Locomotive::Engine.routes.url_helpers

      def redirect_url
        new_locomotive_account_session_path
      end

    end

  end
end