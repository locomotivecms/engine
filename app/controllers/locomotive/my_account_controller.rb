module Locomotive
  class MyAccountController < BaseController

    account_required

    respond_to :json, only: [:regenerate_api_key]

    before_filter :load_account

    layout '/locomotive/layouts/account'

    def edit
      authorize @account
      respond_with @account
    end

    def update
      authorize @account
      @account.update_attributes(account_params)
      respond_with @account, location: edit_my_account_path(anchor: params[:active_tab])
    end

    def regenerate_api_key
      authorize @account, :update?
      @account.regenerate_api_key!
      respond_with({ api_key: @account.api_key }, location: edit_my_account_path)
    end

    private

    def load_account
      @account = current_locomotive_account
    end

    def account_params
      params.require(:account).permit(:name, :email, :password, :password_confirmation, :avatar, :remove_avatar, :locale)
    end

  end
end
