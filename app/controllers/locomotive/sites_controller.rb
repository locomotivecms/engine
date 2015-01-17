module Locomotive
  class SitesController < BaseController

    skip_before_filter :require_site
    skip_before_filter :set_current_content_locale
    skip_before_filter :validate_site_membership

    layout '/locomotive/layouts/without_site'

    def index
      authorize Site
      @sites = service.list
      respond_with @sites
    end

    def new
      authorize Site
      @site = Site.new
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
