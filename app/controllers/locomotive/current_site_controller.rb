module Locomotive
  class CurrentSiteController < BaseController

    sections 'settings', 'site'

    skip_load_and_authorize_resource

    load_and_authorize_resource :class => 'Site'

    respond_to :json, :only => :update

    def edit
    end

    def update
      update! do |success, failure|
        success.html { redirect_to edit_current_site_url(new_host_if_subdomain_changed) }
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
