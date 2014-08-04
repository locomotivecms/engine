module Locomotive
  class SitesController < BaseController

    sections 'sites'

    respond_to :json, only: [:create, :destroy]

    def index
      @sites = service.list
      respond_with @sites, layout: '/locomotive/layouts/without_sidebar'
    end

    def new
      @site = Site.new
      respond_with @site
    end

    def create
      authorize :site
      @site = service.create(params[:site])
      respond_with @site, location: edit_my_account_path
    end

    def destroy
      authorize :site
      @site = self.current_locomotive_account.sites.find(params[:id])

      if @site != current_site
        @site.destroy
      else
        @site.errors.add(:base, 'Can not destroy the site you are logging in now')
      end

      respond_with @site, location: edit_my_account_path
    end

    protected

    def service
      @service ||= Locomotive::SitesService.new(self.current_locomotive_account)
    end

  end
end
