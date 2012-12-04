module Locomotive
  module Api
    class MyAccountController < BaseController

      skip_load_and_authorize_resource

      skip_before_filter :require_site, :set_locale, :set_current_thread_variables

      def show
        respond_with(current_locomotive_account)
      end

      protected

      def self.description
        {
          overall: %{Manage the current account (my account)},
          actions: {
            show: {
              description: %{Return the attributes of my account},
              response: Locomotive::AccountPresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/my_account.json'},
                response: %(TODO)
              }
            }
          }
        }
      end

    end

  end
end

