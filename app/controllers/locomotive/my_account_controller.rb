module Locomotive
  class MyAccountController < BaseController

    sections 'settings', 'account'

    respond_to :json, :only => :update

    helper 'Locomotive::Accounts'

    skip_load_and_authorize_resource

    def edit
      @account = current_locomotive_account
      respond_with @account
    end

    def update
      @account = current_locomotive_account
      @account.update_attributes(params[:account])
      respond_with @account, :location => edit_my_account_url
    end

  end
end
