module Locomotive
  class MyAccountController < BaseController

    sections 'settings', 'account'

    respond_to :json, only: [:update, :regenerate_api_key]

    helper 'Locomotive::Accounts'

    skip_load_and_authorize_resource

    def edit
      @account = current_locomotive_account
      respond_with @account
    end

    def update
      @account = current_locomotive_account
      @account.update_attributes(params[:account])
      respond_with @account, location: edit_my_account_path
    end

    def regenerate_api_key
      @account = current_locomotive_account
      @account.regenerate_api_key!
      respond_with({ api_key: @account.api_key }, location: edit_my_account_path)
    end

  end
end