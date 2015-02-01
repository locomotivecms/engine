module Locomotive
  module Api
    class MyAccountController < Api::BaseController

      account_required except: :create

      before_filter :load_account
      before_filter :must_not_be_logged_in, only: :create

      def show
        authorize @account
        respond_with @account
      end

      def create
        @account = Account.new
        @account.from_presenter(params[:account]).save
        respond_with @account, location: main_app.locomotive_api_my_account_url
      end

      def update
        authorize @account
        @account.from_presenter(params[:account]).save
        respond_with @account, location: main_app.locomotive_api_my_account_url
      end

      private

      def load_account
        @account = current_locomotive_account
      end

      def must_not_be_logged_in
        raise Pundit::NotAuthorizedError.new('You must not be logged in') if current_locomotive_account
      end

      def current_membership
        if current_locomotive_account
          Locomotive::Membership.new(account: current_locomotive_account)
        end
      end

    end

  end
end
