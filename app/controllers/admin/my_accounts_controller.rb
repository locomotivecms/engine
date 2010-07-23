module Admin
  class MyAccountsController < BaseController

    sections 'settings', 'account'

    actions :edit, :update

    respond_to :json, :only => :update

    def update
      update! { edit_admin_my_account_url }
    end

    protected

    def resource
      @account = current_admin
    end

    def begin_of_association_chain; nil; end # not related directly to current_site

  end
end
