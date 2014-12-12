module Locomotive
  class AccountsController < BaseController

    def new
      @account = Account.new(email: params[:email])
      respond_with @account
    end

    def create
      authorize Membership
      @account = Account.create(params[:account])
      current_site.memberships.create(account: @account) if @account.errors.empty?
      respond_with @account, location: edit_current_site_path
    end

  end
end
