module Locomotive
  module Api
    class AccountsController < Api::BaseController

      before_filter :load_account, only: [:show, :update, :destroy]

      skip_before_filter :verify_authenticity_token, only: [:create]
      skip_before_filter :require_account, only: [:create]
      skip_before_filter :require_site, only: [:create]

      def index
        @accounts = self.current_locomotive_account.to_scope(:account, self.current_site)
        @accounts = @accounts.try(:ordered)
        respond_with(@accounts)
      end

      def show
        ApplicationPolicy.new(self.current_locomotive_account, @account).show?
        respond_with(@account)
      end

      def create
        @account = Account.new
        @account.from_presenter(params[:account])
        @account.save
        respond_with(@account)
      end

      def update
        ApplicationPolicy.new(self.current_locomotive_account, @account).update?
        @account.from_presenter(params[:account])
        @account.save
        respond_with(@account)
      end

      def destroy
        ApplicationPolicy.new(self.current_locomotive_account, @account).destroy?
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

      private

      def load_account
        @account = Locomotive::Account.find params[:id]
      end

    end

  end
end
