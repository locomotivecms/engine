module Locomotive
  class AccountsController < BaseController

    def new
      authorize Membership
      @account = Account.new(email: params.require(:email))
      respond_with @account
    end

    def create
      authorize Membership
      @account = Account.create(account_params)
      current_site.memberships.create(account: @account) if @account.errors.empty?
      respond_with @account, location: edit_current_site_path
    end

    private

    def account_params
      params.require(:account).permit(:email, :name, :locale, :password, :password_confirmation)
    end

  end
end
