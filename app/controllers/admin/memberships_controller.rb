module Admin
  class MembershipsController < BaseController
    
    sections 'settings'
    
    def new
      @membership = current_site.memberships.build
    end

    def create
      @membership = current_site.memberships.build(params[:membership])

      case @membership.action_to_take
      when :create_account
        redirect_to new_admin_account_url(:email => @membership.email)
      when :save_it
        current_site.save
        flash_success!
        redirect_to edit_admin_site_url
      when :error
        flash_error! :now => true
        render :action => 'new'
      when :nothing
        flash[:error] = translate_flash_msg(:already_saved)
        redirect_to edit_admin_site_url
      end
    end

    def destroy
      current_site.memberships.find(params[:id]).destroy
      current_site.save

      flash_success!

      redirect_to edit_admin_site_url
    end
  
  end
end