module Admin
  class SitesController < BaseController
  
    sections 'settings'
  
    def new
      @site = Site.new
    end
    
    def create
      @site = Site.new(params[:site])

      if @site.save
        @site.memberships.create :account => @current_admin, :admin => true
        flash_success!
        redirect_to edit_admin_my_account_url
      else
        flash_error!
        render :action => 'new'
      end
    end
  
    def destroy
      @site = current_admin.sites.detect { |s| s._id == params[:id] }
    
      if @site != current_site
        @site.destroy
        flash_success!
      else
        flash_error!
      end
    
      redirect_to edit_admin_my_account_url
    end
    
    protected
    
    def new_host_if_subdomain_changed
      host_from_site = "#{@site.subdomain}.#{Locomotive.config.default_domain}"
      if request.host == host_from_site
        {}
      else
        { :host => "#{host_from_site}:#{request.port}" }
      end
    end
  
  end
end