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
      if @site.domains.include?(request.host)
        {}
      else
        { :host => "#{@site.subdomain}.#{Locomotive.config.default_domain}:#{request.port}" }
      end
    end
  
  end
end