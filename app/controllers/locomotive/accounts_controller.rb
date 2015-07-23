module Locomotive
  class AccountsController < BaseController

    account_required & within_site

    def new
      authorize Membership
      @account = Account.new(email: params[:email])
      respond_with @account
    end

    def create
      authorize Membership
      @account = Account.create(account_params)
      service.create(@account) if @account.errors.empty?
      respond_with @account, location: edit_current_site_path(current_site)
    end

    private

    def account_params
      params.require(:account).permit(:email, :name, :locale, :password, :password_confirmation)
    end

    def service
      policy = MembershipPolicy.new(pundit_user, @membership || Membership)
      @service ||= Locomotive::MembershipService.new(current_site, policy)
    end

  end
end
