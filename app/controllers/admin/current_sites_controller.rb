module Admin
  class CurrentSitesController < BaseController

    defaults :instance_name => 'site'

    sections 'settings', 'site'

    actions :edit, :update

    respond_to :json, :only => :update

    def update
      update! do |success, failure|
        success.html { redirect_to edit_admin_current_site_url(new_host_if_subdomain_changed) }
      end
    end

    protected

    def resource
      @site = current_site
    end

    def new_host_if_subdomain_changed
      if !Locomotive.config.manage_subdomain? || @site.domains.include?(request.host)
        {}
      else
        { :host => site_url(@site, { :fullpath => false, :protocol => false }) }
      end
    end

  end
end
