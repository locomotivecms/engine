module Locomotive
  module Api
    class MyAccountController < BaseController

      before_filter :load_account
      before_filter :must_not_be_logged_in, only: :create

      skip_before_filter :set_locale

      skip_before_filter :authenticate_locomotive_account_from_token!, only: :create
      skip_before_filter :require_account, only: :create
      skip_before_filter :require_site
      skip_before_filter :validate_site_membership

      def show
        authorize @account
        respond_with @account
      end

      def create
        @account = Account.new
        @account.from_presenter(account_params).save
        respond_with @account, location: main_app.locomotive_api_my_account_url
      end

      def update
        authorize @account
        @account.from_presenter(account_params).save
        respond_with @account, location: main_app.locomotive_api_my_account_url
      end

      private

      def load_account
        @account = current_locomotive_account
      end

      def account_params
        params.require(:account).permit(:name, :email, :password, :password_confirmation)
      end

      def must_not_be_logged_in
        raise Pundit::NotAuthorizedError.new('You must be not logged in') if current_locomotive_account
      end

      def current_membership
        if current_locomotive_account
          Locomotive::Membership.new(account: current_locomotive_account)
        end
      end

    end

  end
end
