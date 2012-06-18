module Locomotive
  module Api
    class AccountsController < BaseController

      #load_and_authorize_resource :class => Locomotive::Account
      #FIXME: qwill not auto-load
      skip_load_and_authorize_resource

      def index
        @accounts = Locomotive::Account.all
        authorize! :index, @account
        respond_with(@accounts)
      end

      def show
        @account = Locomotive::Account.find(params[:id])
        authorize! :show, @account
        respond_with(@account)
      end

      def create
        build_params = params[:account] # force author by default
        @account = current_site.accounts.create(build_params)
        authorize! :create, @account
        @account_presenter = @account.to_presenter
        @account_presenter.update_attributes(params[:account])
        respond_with(@account)
      end

      def destroy
        @account = Locomotive::Account.find(params[:id])
        authorize! :destroy, @account
        @account.destroy
        respond_with(@account)
      end

      protected

      def load_account
        @account ||= load_accounts.find(params[:id])
      end

      def load_accounts
        @accounts ||= current_site.accounts
      end

    end

  end
end

