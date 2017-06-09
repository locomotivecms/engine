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
      if needs_password?
        @account.update_with_password(account_params)
      else
        @account.update_attributes(account_params)
      end
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
      params.require(:account).permit(
        :name, :email, :current_password, :password, :password_confirmation,
        :avatar, :remove_avatar, :locale
      )
    end

    def needs_password?
      params[:account][:email].present? || params[:account][:password].present?
    end

  end
end
