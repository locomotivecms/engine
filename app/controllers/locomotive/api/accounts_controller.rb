module Locomotive
  module Api
    class AccountsController < Api::BaseController

      load_and_authorize_resource :class => Locomotive::Account

      skip_load_and_authorize_resource :only => [ :show, :create ]

      def index
        @accounts = Locomotive::Account.all
        authorize! :index, @accounts
        respond_with(@accounts)
      end

      def show
        @account = Locomotive::Account.find(params[:id])
        authorize! :show, @account
        respond_with(@account)
      end

      def create
        @account = Locomotive::Account.from_presenter(params[:account])
        authorize! :create, @account
        @account.save
        respond_with(@account)
      end

      def destroy
        @account = Locomotive::Account.find(params[:id])
        authorize! :destroy, @account
        @account.destroy
        respond_with(@account)
      end

    end

  end
end

