module Locomotive
  module Api
    class AccountsController < Api::BaseController

      load_and_authorize_resource class: Locomotive::Account

      def index
        @accounts = @accounts.ordered
        respond_with(@accounts)
      end

      def show
        respond_with(@account)
      end

      def create
        @account.from_presenter(params[:account])
        @account.save
        respond_with(@account)
      end

      def update
        @account.from_presenter(params[:account])
        @account.save
        respond_with(@account)
      end

      def destroy
        @account.destroy
        respond_with(@account)
      end

      protected

      def self.description
        {
          overall: %{Manage the accounts (only if logged as an admin) no matter the site they belong to},
          actions: {
            index: {
              description: %{Return all the accounts},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/accounts.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of an account},
              response: Locomotive::AccountPresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/accounts/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create an account},
              params: Locomotive::AccountPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/accounts.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete an account},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/accounts.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

    end

  end
end

