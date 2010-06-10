module Admin
  class MyAccountsController < BaseController
    
    sections 'settings', 'account'
    
    def edit
      @account = current_admin
    end
    
    def update
      @account = current_admin
      if @account.update_attributes(params[:account])
        flash_success!      
        redirect_to edit_admin_my_account_url
      else
        render :action => :edit
      end
    end
    
  end
end