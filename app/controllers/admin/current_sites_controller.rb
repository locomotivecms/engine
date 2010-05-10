module Admin
  class CurrentSitesController < BaseController
  
    sections 'settings', 'site'
  
    def edit
      @site = current_site
    end
    
    def update
      @site = current_site
      if @site.update_attributes(params[:site])
        flash_success!
        redirect_to edit_admin_current_site_url(new_host_if_subdomain_changed)
      else
        flash_error!
        render :action => :edit
      end
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