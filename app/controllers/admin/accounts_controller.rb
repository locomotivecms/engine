module Admin
  class AccountsController < BaseController
    
    sections 'settings'
    
    def new
      @account = Account.new(:email => params[:email])
    end
    
    def create
      @account = Account.new(params[:account])

      if @account.save
        current_site.memberships.create(:account => @account)
        flash_success!
        redirect_to edit_admin_current_site_url
      else
        flash_error!
        render :action => 'new'
      end
    end  
    
  end
end