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

Devise.setup do |config|
  config.secret_key = Rails.application.secret_key_base
end
