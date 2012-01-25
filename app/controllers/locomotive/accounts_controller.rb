module Locomotive
  class AccountsController < BaseController

    sections 'settings'

    def new
      @account = Account.new(:email => params[:email])
      respond_with @account
    end

    def create
      @account = Account.create(params[:account])
      current_site.memberships.create(:account => @account) if @account.errors.empty?
      respond_with @account, :location => edit_current_site_url
    end

  end
end
