module Locomotive
  module Api
    class MyAccountController < BaseController

      skip_load_and_authorize_resource

      skip_before_filter :require_site, :set_locale, :set_current_thread_variables

      skip_before_filter :require_account, only: [:create]

      def show
        respond_with(current_locomotive_account)
      end

      def create
        @account = Locomotive::Account.new
        @account.from_presenter(params[:account])
        @account.save
        respond_with(@account)
      end

      def update
        current_locomotive_account.from_presenter(params[:account])
        current_locomotive_account.save
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

