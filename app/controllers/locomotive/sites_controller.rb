module Locomotive
  class SitesController < BaseController

    account_required

    layout '/locomotive/layouts/account'

    def index
      authorize Site
      @sites = service.list
      respond_with @sites
    end

    def new
      authorize Site
      @site = service.build_new
      respond_with @site
    end

    def create
      authorize Site
      @site = service.create(site_params)
      respond_with @site, location: -> { dashboard_path(@site) }
    end

    private

    def service
      @service ||= Locomotive::SiteService.new(self.current_locomotive_account)
    end

    def site_params
      params.require(:site).permit(:name, :handle)
    end

  end
end
